#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zlib'

ROOT_DIR = File.expand_path(ENV.fetch('TUTORIAL_ROOT', '..'), __dir__)
Dir.chdir(ROOT_DIR)

errors = []
tutorials = Dir.glob('[0-9][0-9][0-9]_*').select { |path| File.directory?(path) }.sort
tutorial_ids = tutorials.map { |tutorial| tutorial[/\A\d{3}/] }
expected_tutorial_ids = (1..tutorial_ids.length).map { |index| format('%03d', index) }
unity_project_versions = {
  '001_collisions' => '001_collisions/ProjectSettings/ProjectVersion.txt',
  '003_augmented_reality' => '003_augmented_reality/AR Example Pokemon Go/ProjectSettings/ProjectVersion.txt'
}.freeze
blender_project_versions = {
  '002_characters/Pikachu.blend' => '272',
  '002_characters/Pokeball.blend' => '277'
}.freeze
fbx_project_versions = {
  '001_collisions/Assets/Objects/Pikachu.FBX' => 7300,
  '001_collisions/Assets/Objects/pokeball2.fbx' => 7400
}.freeze
tutorial_readme_requirements = {
  '001_collisions' => ['Unity', 'PokemonThrow.unity'],
  '002_characters' => ['Blender', 'Pikachu.blend', 'Pokeball.blend'],
  '003_augmented_reality' => ['Kudan', 'camera', 'PokemonScene.unity'],
  '004_slippy_maps' => ['PokemonMap.unitypackage', 'location']
}.freeze

unless tutorial_ids == expected_tutorial_ids
  errors << "tutorial directories must be numbered contiguously from 001: #{tutorials.join(', ')}"
end

def require_file(errors, path, message)
  errors << message unless File.file?(path)
end

def require_signature(errors, path, signature, format)
  return unless File.file?(path)

  actual = File.binread(path, signature.bytesize)
  errors << "#{path} must have a valid #{format} signature" unless actual == signature
rescue EOFError
  errors << "#{path} must have a valid #{format} signature"
end

def validate_png_container(errors, path)
  return unless File.file?(path)

  data = File.binread(path)
  offset = 8
  first_chunk = true
  seen_idat = false

  loop do
    if offset == data.bytesize
      errors << "#{path} must end with exactly one PNG IEND chunk"
      return
    end

    if offset + 12 > data.bytesize
      errors << "#{path} must have valid PNG chunk framing"
      return
    end

    length = data.byteslice(offset, 4).unpack1('N')
    chunk_end = offset + 12 + length
    if chunk_end > data.bytesize
      errors << "#{path} must have valid PNG chunk framing"
      return
    end

    type = data.byteslice(offset + 4, 4)
    payload = data.byteslice(offset + 8, length)
    expected_crc = data.byteslice(offset + 8 + length, 4).unpack1('N')
    unless Zlib.crc32(type + payload) == expected_crc
      errors << "#{path} must have valid PNG chunk CRCs"
      return
    end

    if first_chunk && (type != 'IHDR' || length != 13)
      errors << "#{path} must start with one valid PNG IHDR chunk"
      return
    end

    seen_idat = true if type == 'IDAT'
    if type == 'IEND'
      unless length.zero? && seen_idat && chunk_end == data.bytesize
        errors << "#{path} must end with exactly one PNG IEND chunk"
      end
      return
    end

    first_chunk = false
    offset = chunk_end
  end
end

def validate_jpeg_container(errors, path)
  return unless File.file?(path)

  errors << "#{path} must end with a JPEG end-of-image marker" unless File.binread(path).end_with?("\xff\xd9".b)
end

def validate_blender_header(errors, path, expected_version)
  return unless File.file?(path)

  header = File.binread(path, 12)
  if header.bytesize != 12
    errors << "#{path} must have a complete 12-byte Blender header"
    return
  end

  errors << "#{path} must have a valid Blender signature" unless header.byteslice(0, 7) == 'BLENDER'.b
  errors << "#{path} must have a valid Blender pointer-width marker" unless ['_', '-'].include?(header.byteslice(7, 1))
  errors << "#{path} must have a valid Blender endianness marker" unless ['v', 'V'].include?(header.byteslice(8, 1))

  version = header.byteslice(9, 3)
  unless version.match?(/\A\d{3}\z/)
    errors << "#{path} must have a three-digit Blender version"
    return
  end

  errors << "#{path} must retain Blender version #{expected_version}" unless version == expected_version
end

def validate_binary_fbx(errors, path, expected_version)
  return unless File.file?(path)

  size = File.size(path)
  header = File.binread(path, 27)
  signature = "Kaydara FBX Binary  \x00\x1a\x00".b
  unless header.start_with?(signature)
    errors << "#{path} must have a valid binary FBX signature"
    return
  end

  if size < 160
    errors << "#{path} must have a complete binary FBX container"
    return
  end

  header_version = header.byteslice(23, 4).unpack1('V')
  errors << "#{path} must retain binary FBX version #{expected_version}" unless header_version == expected_version

  footer = File.binread(path, 140, size - 140)
  footer_version = footer.byteslice(0, 4).unpack1('V')
  errors << "#{path} must have matching binary FBX header and footer versions" unless footer_version == header_version

  footer_padding = footer.byteslice(4, 120)
  errors << "#{path} must have zeroed binary FBX footer padding" unless footer_padding == "\x00".b * 120

  footer_magic = [0xf8, 0x5a, 0x8c, 0x6a, 0xde, 0xf5, 0xd9, 0x7e,
                  0xec, 0xe9, 0x0c, 0xe3, 0x75, 0x8f, 0x29, 0x0b].pack('C*')
  errors << "#{path} must end with the binary FBX footer magic" unless footer.end_with?(footer_magic)
end

tutorials.each do |tutorial|
  readme = File.join(tutorial, 'README.md')
  require_file(errors, readme, "#{tutorial} is missing README.md")
  next unless File.file?(readme)

  content = File.read(readme)
  image_tags = content.scan(/<img\b[^>]*>/i)
  referenced_images = []

  image_tags.each do |tag|
    src = tag[/\ssrc=(["'])(.*?)\1/i, 2]
    width = tag[/\swidth=(["'])(.*?)\1/i, 2]
    alt = tag[/\salt=(["'])(.*?)\1/i, 2]

    if src.nil? || src.empty?
      errors << "#{readme} has an image tag without a quoted src: #{tag}"
      next
    end

    errors << "#{readme} image tag for #{src} is missing a quoted width attribute" if width.nil? || width.empty?
    errors << "#{readme} image tag for #{src} is missing a quoted alt attribute" if alt.nil? || alt.strip.empty?

    next if src.start_with?('http://', 'https://')

    target = File.expand_path(src, tutorial)
    referenced_images << target
    errors << "#{readme} references missing image #{src}" unless File.file?(target)
  end

  tutorial_id = tutorial[/\A\d{3}/]
  screenshot_dir = File.join('screenshots', tutorial_id)
  if File.directory?(screenshot_dir)
    screenshots = Dir.glob(File.join(screenshot_dir, '*')).select { |path| File.file?(path) }

    if screenshots.any? && referenced_images.empty?
      errors << "#{readme} must reference at least one local screenshot from #{screenshot_dir}"
    end

    screenshots.each do |screenshot|
      expanded_screenshot = File.expand_path(screenshot)
      next if referenced_images.include?(expanded_screenshot)

      errors << "#{readme} does not reference screenshot #{screenshot}"
    end
  end
end

unity_project_versions.each do |tutorial, version_path|
  require_file(errors, version_path, "#{tutorial} is missing Unity ProjectVersion.txt")
end

require_file(errors, '001_collisions/Assets/Scenes/PokemonThrow.unity', '001_collisions is missing PokemonThrow.unity')
require_file(errors, '002_characters/Pikachu.blend', '002_characters is missing Pikachu.blend')
require_file(errors, '002_characters/Pokeball.blend', '002_characters is missing Pokeball.blend')
require_file(errors, '003_augmented_reality/AR Example Pokemon Go/Assets/Scenes/PokemonScene.unity', '003_augmented_reality is missing PokemonScene.unity')
require_file(errors, '004_slippy_maps/PokemonMap.unitypackage', '004_slippy_maps is missing PokemonMap.unitypackage')
require_file(errors, 'ASSET_NOTICES.md', 'ASSET_NOTICES.md is missing')
require_file(errors, 'docs/plans/2026-06-08-asset-notices-baseline.md', 'canonical docs/plans asset notice plan is missing')
require_file(errors, 'docs/plans/2026-06-08-screenshot-inventory-validation.md', 'canonical docs/plans screenshot inventory plan is missing')
require_file(errors, 'docs/plans/2026-06-09-loose-screenshot-inventory.md', 'canonical docs/plans loose screenshot plan is missing')
require_file(errors, 'docs/plans/2026-06-09-unity-scene-reference-validation.md', 'canonical docs/plans Unity scene reference plan is missing')
require_file(errors, 'docs/plans/2026-06-09-unity-version-toolchain-validation.md', 'canonical docs/plans Unity version toolchain plan is missing')
require_file(errors, 'docs/plans/2026-06-09-screenshot-permission-validation.md', 'canonical docs/plans screenshot permission plan is missing')
require_file(errors, 'docs/plans/2026-06-09-tutorial-readme-setup-validation.md', 'canonical docs/plans tutorial README setup plan is missing')
require_file(errors, 'docs/plans/2026-06-09-asset-permission-validation.md', 'canonical docs/plans asset permission plan is missing')
require_file(errors, 'docs/plans/2026-06-09-unity-project-permission-validation.md', 'canonical docs/plans Unity project permission plan is missing')
require_file(errors, 'docs/plans/2026-06-09-tutorial-image-alt-validation.md', 'canonical docs/plans tutorial image alt plan is missing')
require_file(errors, 'docs/plans/2026-06-10-tutorial-sequence-validation.md', 'canonical docs/plans tutorial sequence plan is missing')
require_file(errors, 'docs/plans/2026-06-10-hosted-tutorial-validation.md', 'canonical docs/plans hosted tutorial validation plan is missing')
require_file(errors, 'docs/plans/2026-06-10-unity-metadata-validation.md', 'canonical docs/plans Unity metadata validation plan is missing')
require_file(errors, 'docs/plans/2026-06-12-asset-signature-validation.md', 'canonical docs/plans asset signature validation plan is missing')
require_file(errors, 'docs/plans/2026-06-13-screenshot-container-integrity.md', 'canonical docs/plans screenshot container integrity plan is missing')
require_file(errors, 'docs/plans/2026-06-13-blender-header-metadata.md', 'canonical docs/plans Blender header metadata plan is missing')
require_file(errors, 'docs/plans/2026-06-13-fbx-container-integrity.md', 'canonical docs/plans FBX container integrity plan is missing')
require_file(errors, '.github/CODEOWNERS', 'repository CODEOWNERS is missing')
require_file(errors, '.github/workflows/check.yml', 'hosted tutorial validation workflow is missing')
require_file(errors, 'TOOLCHAIN.md', 'TOOLCHAIN.md is missing')
require_file(errors, 'scripts/test-tutorial-assets.sh', 'tutorial asset mutation test is missing')

if File.file?('.github/workflows/check.yml')
  workflow = File.read('.github/workflows/check.yml')
  unless workflow.lines.include?("permissions:\n") && workflow.lines.include?("  contents: read\n")
    errors << 'hosted tutorial validation must use read-only repository contents permission'
  end
  unless workflow.lines.include?("  push:\n") && !workflow.include?('branches:')
    errors << 'hosted tutorial validation must run for pushes on every branch'
  end
  unless workflow.include?('uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10')
    errors << 'hosted tutorial validation must pin the reviewed actions/checkout v6 commit'
  end
  unless workflow.include?('persist-credentials: false')
    errors << 'hosted tutorial validation must disable checkout credential persistence'
  end
  errors << 'hosted tutorial validation must use exactly one checkout action' unless workflow.scan(/uses: actions\/checkout@/).length == 1
  errors << 'hosted tutorial validation must set credential persistence exactly once' unless workflow.scan(/persist-credentials:/).length == 1
  errors << 'hosted tutorial validation must keep one permissions block' unless workflow.scan(/^permissions:$/).length == 1
  errors << 'hosted tutorial validation must not grant write permissions' if workflow.match?(/^\s+[\w-]+:\s+write\s*$/)
  unless workflow.match?(/^\s+run: make check$/)
    errors << 'hosted tutorial validation must run the canonical make check gate'
  end
end

workflow_files = Dir.glob('.github/workflows/**/*').select { |path| File.file?(path) }.sort
errors << "check.yml must be the repository's only hosted workflow" unless workflow_files == ['.github/workflows/check.yml']

if File.file?('.github/CODEOWNERS') && File.read('.github/CODEOWNERS').strip != '* @garethpaul'
  errors << 'CODEOWNERS must assign the repository to @garethpaul'
end

if File.file?('README.md')
  readme = File.read('README.md')
  tutorials.each do |tutorial|
    errors << "README.md missing tutorial directory #{tutorial}" unless readme.include?(tutorial)
  end
  unless readme.include?('binary file signatures')
    errors << 'README.md must document archived asset binary file signatures'
  end
  unless readme.include?('PNG chunk CRCs') && readme.include?('terminal image markers')
    errors << 'README.md must document screenshot container integrity checks'
  end
  errors << 'README.md must document Blender header metadata checks' unless readme.include?('Blender header metadata')
  unless readme.include?('Binary FBX checks') && readme.include?('footer versions') && readme.include?('terminal footer magic')
    errors << 'README.md must document binary FBX container integrity checks'
  end
end

{
  '001_collisions' => '001_collisions/Assets/Scenes/PokemonThrow.unity',
  '003_augmented_reality' => '003_augmented_reality/AR Example Pokemon Go/Assets/Scenes/PokemonScene.unity'
}.each do |tutorial, scene_path|
  readme = File.join(tutorial, 'README.md')
  next unless File.file?(readme)

  scene_name = File.basename(scene_path)
  errors << "#{readme} must mention Unity scene #{scene_name}" unless File.read(readme).include?(scene_name)
end

loose_screenshots = Dir.glob(File.join('screenshots', '*')).select { |path| File.file?(path) }.sort
unless loose_screenshots.empty?
  {
    'README.md' => File.file?('README.md') ? File.read('README.md') : '',
    'ASSET_NOTICES.md' => File.file?('ASSET_NOTICES.md') ? File.read('ASSET_NOTICES.md') : ''
  }.each do |doc_path, content|
    loose_screenshots.each do |screenshot|
      errors << "#{doc_path} must mention loose screenshot #{screenshot}" unless content.include?(screenshot)
    end
  end
end

screenshot_files = Dir.glob(File.join('screenshots', '**', '*')).select { |path| File.file?(path) }.sort
screenshot_files.each do |screenshot|
  case File.extname(screenshot).downcase
  when '.png'
    require_signature(errors, screenshot, [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a].pack('C*'), 'PNG')
    validate_png_container(errors, screenshot)
  when '.jpg', '.jpeg'
    require_signature(errors, screenshot, [0xff, 0xd8, 0xff].pack('C*'), 'JPEG')
    validate_jpeg_container(errors, screenshot)
  end

  next if (File.stat(screenshot).mode & 0o111).zero?

  errors << "#{screenshot} must not be executable"
end

asset_files = Dir.glob(['**/*.blend', '**/*.unitypackage', '**/*.fbx', '**/*.FBX', '**/*.tga']).select { |path| File.file?(path) }.sort
asset_files.each do |asset|
  next if (File.stat(asset).mode & 0o111).zero?

  errors << "#{asset} must not be executable"
end

blender_project_versions.each do |blend, expected_version|
  validate_blender_header(errors, blend, expected_version)
end

Dir.glob('**/*.unitypackage').select { |path| File.file?(path) }.sort.each do |unity_package|
  require_signature(errors, unity_package, [0x1f, 0x8b].pack('C*'), 'gzip')
end

fbx_project_versions.each do |fbx, expected_version|
  validate_binary_fbx(errors, fbx, expected_version)
end

unity_project_files = Dir.glob([
  '**/*.unity',
  '**/*.asset',
  '**/*.mat',
  '**/*.physicMaterial',
  '**/*.cs',
  '**/*.js',
  '**/*.meta'
]).select { |path| File.file?(path) }.sort
unity_project_files.each do |project_file|
  next if (File.stat(project_file).mode & 0o111).zero?

  errors << "#{project_file} must not be executable"
end

unity_asset_roots = Dir.glob('[0-9][0-9][0-9]_*/**/Assets').select { |path| File.directory?(path) }
unity_metadata_guids = {}
unity_asset_roots.each do |asset_root|
  Dir.glob(File.join(asset_root, '**', '*'), File::FNM_DOTMATCH).sort.each do |asset|
    next if ['.', '..'].include?(File.basename(asset)) || asset.end_with?('.meta')

    errors << "#{asset} is missing Unity metadata #{asset}.meta" unless File.file?("#{asset}.meta")
  end

  Dir.glob(File.join(asset_root, '**', '*.meta')).sort.each do |metadata|
    asset = metadata.delete_suffix('.meta')
    errors << "#{metadata} is orphaned Unity metadata" unless File.exist?(asset)

    guid = File.read(metadata)[/^guid:\s*([0-9a-f]{32})$/, 1]
    if guid.nil?
      errors << "#{metadata} must declare a 32-character lowercase hexadecimal Unity guid"
    elsif unity_metadata_guids.key?(guid)
      errors << "#{metadata} duplicates Unity guid #{guid} from #{unity_metadata_guids.fetch(guid)}"
    else
      unity_metadata_guids[guid] = metadata
    end
  end
end

tutorial_readme_requirements.each do |tutorial, required_terms|
  readme = File.join(tutorial, 'README.md')
  next unless File.file?(readme)

  content = File.read(readme)
  required_terms.each do |term|
    errors << "#{readme} must document #{term} setup assumption" unless content.match?(/#{Regexp.escape(term)}/i)
  end
end

if File.file?('TOOLCHAIN.md')
  toolchain = File.read('TOOLCHAIN.md')
  tutorials.each do |tutorial|
    errors << "TOOLCHAIN.md missing row for #{tutorial}" unless toolchain.include?("| #{tutorial} |")
  end

  {
    '001_collisions' => 'Unity 5.3.5f1',
    '002_characters' => 'Blender',
    '003_augmented_reality' => 'Unity 5.4.0f1',
    '004_slippy_maps' => 'PokemonMap.unitypackage'
  }.each do |tutorial, requirement|
    errors << "TOOLCHAIN.md missing #{requirement} for #{tutorial}" unless toolchain.include?(requirement)
  end

  blender_project_versions.each do |path, version|
    documented_version = "Blender #{version[0]}.#{version[1..]}"
    unless toolchain.include?(File.basename(path)) && toolchain.include?(documented_version)
      errors << "TOOLCHAIN.md must document #{documented_version} for #{path}"
    end
  end

  fbx_project_versions.each do |path, version|
    unless toolchain.include?(File.basename(path)) && toolchain.include?("binary FBX #{version}")
      errors << "TOOLCHAIN.md must document binary FBX #{version} for #{path}"
    end
  end

  %w[Kudan camera location].each do |term|
    errors << "TOOLCHAIN.md must document #{term} assumptions" unless toolchain.match?(/#{Regexp.escape(term)}/i)
  end

  unity_project_versions.each do |tutorial, version_path|
    next unless File.file?(version_path)

    version = File.read(version_path)[/^m_EditorVersion:\s*(\S+)/, 1]
    if version.nil? || version.empty?
      errors << "#{version_path} is missing m_EditorVersion"
      next
    end

    row = toolchain.lines.find { |line| line.start_with?("| #{tutorial} |") }
    errors << "TOOLCHAIN.md missing Unity editor version #{version} for #{tutorial}" unless row&.include?(version)
  end
end

if File.file?('ASSET_NOTICES.md')
  notices = File.read('ASSET_NOTICES.md')
  tutorials.each do |tutorial|
    errors << "ASSET_NOTICES.md missing row for #{tutorial}" unless notices.include?("| #{tutorial} |")
  end

  %w[Pokemon Nintendo Niantic educational non-affiliation commercial].each do |term|
    errors << "ASSET_NOTICES.md must document #{term} assumptions" unless notices.match?(/#{Regexp.escape(term)}/i)
  end
end

if File.file?('docs/plans/2026-06-08-asset-notices-baseline.md')
  plan = File.read('docs/plans/2026-06-08-asset-notices-baseline.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans asset notice plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-08-screenshot-inventory-validation.md')
  plan = File.read('docs/plans/2026-06-08-screenshot-inventory-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans screenshot inventory plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-loose-screenshot-inventory.md')
  plan = File.read('docs/plans/2026-06-09-loose-screenshot-inventory.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans loose screenshot plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-unity-scene-reference-validation.md')
  plan = File.read('docs/plans/2026-06-09-unity-scene-reference-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans Unity scene reference plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-unity-version-toolchain-validation.md')
  plan = File.read('docs/plans/2026-06-09-unity-version-toolchain-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans Unity version toolchain plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-screenshot-permission-validation.md')
  plan = File.read('docs/plans/2026-06-09-screenshot-permission-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans screenshot permission plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-tutorial-readme-setup-validation.md')
  plan = File.read('docs/plans/2026-06-09-tutorial-readme-setup-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans tutorial README setup plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-asset-permission-validation.md')
  plan = File.read('docs/plans/2026-06-09-asset-permission-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans asset permission plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-unity-project-permission-validation.md')
  plan = File.read('docs/plans/2026-06-09-unity-project-permission-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans Unity project permission plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-09-tutorial-image-alt-validation.md')
  plan = File.read('docs/plans/2026-06-09-tutorial-image-alt-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans tutorial image alt plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-10-tutorial-sequence-validation.md')
  plan = File.read('docs/plans/2026-06-10-tutorial-sequence-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans tutorial sequence plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-10-hosted-tutorial-validation.md')
  plan = File.read('docs/plans/2026-06-10-hosted-tutorial-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans hosted tutorial validation plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-10-unity-metadata-validation.md')
  plan = File.read('docs/plans/2026-06-10-unity-metadata-validation.md')
  unless plan.include?('Status: Completed') && plan.include?('make check')
    errors << 'canonical docs/plans Unity metadata validation plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-12-asset-signature-validation.md')
  plan = File.read('docs/plans/2026-06-12-asset-signature-validation.md')
  unless plan.match?(/^Status: Completed$/) && plan.include?('make check')
    errors << 'canonical docs/plans asset signature plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-13-blender-header-metadata.md')
  plan = File.read('docs/plans/2026-06-13-blender-header-metadata.md')
  unless plan.match?(/^Status: Completed$/) &&
         plan.include?('Ruby 2.7') &&
         plan.include?('Ruby 3.3') &&
         plan.include?('hostile mutations rejected') &&
         plan.include?('git diff --check') &&
         plan.include?('secret, captured-prompt, generated-artifact, specification, archived-asset, and dependency scan')
    errors << 'canonical docs/plans Blender header metadata plan must preserve completed verification evidence'
  end
end

if File.file?('docs/plans/2026-06-13-screenshot-container-integrity.md')
  plan = File.read('docs/plans/2026-06-13-screenshot-container-integrity.md')
  unless plan.match?(/^Status: Completed$/) && plan.include?('make check')
    errors << 'canonical docs/plans screenshot container integrity plan must be completed and record make check'
  end
end

if File.file?('docs/plans/2026-06-13-fbx-container-integrity.md')
  plan = File.read('docs/plans/2026-06-13-fbx-container-integrity.md')
  unless plan.match?(/^Status: Completed$/) &&
         plan.include?('Ruby 2.7') &&
         plan.include?('Ruby 3.3') &&
         plan.include?('hostile mutations rejected') &&
         plan.include?('git diff --check') &&
         plan.include?('secret, captured-prompt, generated-artifact, specification, archived-asset, and dependency scan')
    errors << 'canonical docs/plans FBX container integrity plan must preserve completed verification evidence'
  end
end

if File.file?('scripts/test-tutorial-assets.sh')
  mutation_test = File.read('scripts/test-tutorial-assets.sh')
  errors << 'tutorial asset mutation test must validate the clean baseline first' unless mutation_test.include?('"$VALIDATOR" >/dev/null')
  [
    'assert_rejected "PNG" "screenshots/001/001.png" "must have a valid PNG signature"',
    'assert_rejected "JPEG" "screenshots/004/001.jpg" "must have a valid JPEG signature"',
    'assert_rejected "PNG-CRC" "screenshots/001/001.png" "must have valid PNG chunk CRCs" "corrupt-png"',
    'assert_rejected "PNG-IEND" "screenshots/001/002.png" "must end with exactly one PNG IEND chunk" "truncate-png"',
    'assert_rejected "PNG-trailing" "screenshots/002/001.png" "must end with exactly one PNG IEND chunk" "append-png"',
    'assert_rejected "JPEG-EOI" "screenshots/004/001.jpg" "must end with a JPEG end-of-image marker" "truncate-jpeg"',
    'assert_rejected "Blender" "002_characters/Pikachu.blend" "must have a valid Blender signature"',
    'assert_rejected "Blender-pointer" "002_characters/Pikachu.blend" "must have a valid Blender pointer-width marker" "blender-pointer"',
    'assert_rejected "Blender-endian" "002_characters/Pikachu.blend" "must have a valid Blender endianness marker" "blender-endian"',
    'assert_rejected "Blender-version-shape" "002_characters/Pikachu.blend" "must have a three-digit Blender version" "blender-version-shape"',
    'assert_rejected "Blender-version" "002_characters/Pikachu.blend" "must retain Blender version 272" "blender-version"',
    'assert_rejected "Blender-truncated" "002_characters/Pikachu.blend" "must have a complete 12-byte Blender header" "truncate-blender"',
    'assert_rejected "FBX-header-version" "001_collisions/Assets/Objects/Pikachu.FBX" "must retain binary FBX version 7300" "fbx-header-version"',
    'assert_rejected "FBX-footer-version" "001_collisions/Assets/Objects/Pikachu.FBX" "must have matching binary FBX header and footer versions" "fbx-footer-version"',
    'assert_rejected "FBX-footer-padding" "001_collisions/Assets/Objects/pokeball2.fbx" "must have zeroed binary FBX footer padding" "fbx-footer-padding"',
    'assert_rejected "FBX-truncated" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a complete binary FBX container" "truncate-fbx"',
    'assert_rejected "FBX-footer-missing" "001_collisions/Assets/Objects/Pikachu.FBX" "must end with the binary FBX footer magic" "strip-fbx-footer"',
    'assert_rejected "FBX-trailing" "001_collisions/Assets/Objects/pokeball2.fbx" "must end with the binary FBX footer magic" "append-fbx"',
    'assert_rejected "gzip" "004_slippy_maps/PokemonMap.unitypackage" "must have a valid gzip signature"',
    'assert_rejected "binary-FBX" "001_collisions/Assets/Objects/Pikachu.FBX" "must have a valid binary FBX signature"'
  ].each do |contract|
    errors << "tutorial asset mutation test must preserve: #{contract}" unless mutation_test.include?(contract)
  end
  errors << 'tutorial asset mutation test must use an isolated root' unless mutation_test.include?('TUTORIAL_ROOT=')
end

if File.file?('Makefile') && !File.read('Makefile').include?('scripts/test-tutorial-assets.sh')
  errors << 'Makefile test gate must run scripts/test-tutorial-assets.sh'
end

if File.file?('Makefile')
  makefile = File.read('Makefile')
  [
    'override REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))',
    'cd "$(REPO_ROOT)" && scripts/check-tutorial-assets.rb',
    'cd "$(REPO_ROOT)" && scripts/test-tutorial-assets.sh'
  ].each do |contract|
    errors << "Makefile must remain caller-directory independent: #{contract}" unless makefile.include?(contract)
  end
end

if File.file?('docs/plans/2026-06-14-location-independent-make.md')
  plan = File.read('docs/plans/2026-06-14-location-independent-make.md')
  [
    'Status: Completed',
    'Ruby 2.7.0',
    'Ruby 3.3',
    'absolute Makefile path from /tmp',
    'REPO_ROOT=/tmp',
    'three isolated hostile mutations',
    'git diff --check',
    'credential-pattern'
  ].each do |evidence|
    errors << "location-independent Make plan must preserve evidence: #{evidence}" unless plan.include?(evidence)
  end
else
  errors << 'docs/plans/2026-06-14-location-independent-make.md is missing'
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Tutorial asset check passed for #{tutorials.length} tutorials."
