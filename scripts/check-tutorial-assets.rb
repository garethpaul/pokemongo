#!/usr/bin/env ruby
# frozen_string_literal: true

errors = []
tutorials = Dir.glob('[0-9][0-9][0-9]_*').select { |path| File.directory?(path) }.sort
unity_project_versions = {
  '001_collisions' => '001_collisions/ProjectSettings/ProjectVersion.txt',
  '003_augmented_reality' => '003_augmented_reality/AR Example Pokemon Go/ProjectSettings/ProjectVersion.txt'
}.freeze
tutorial_readme_requirements = {
  '001_collisions' => ['Unity', 'PokemonThrow.unity'],
  '002_characters' => ['Blender', 'Pikachu.blend', 'Pokeball.blend'],
  '003_augmented_reality' => ['Kudan', 'camera', 'PokemonScene.unity'],
  '004_slippy_maps' => ['PokemonMap.unitypackage', 'location']
}.freeze

def require_file(errors, path, message)
  errors << message unless File.file?(path)
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

    if src.nil? || src.empty?
      errors << "#{readme} has an image tag without a quoted src: #{tag}"
      next
    end

    errors << "#{readme} image tag for #{src} is missing a quoted width attribute" if width.nil? || width.empty?

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
require_file(errors, 'TOOLCHAIN.md', 'TOOLCHAIN.md is missing')

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
  next if (File.stat(screenshot).mode & 0o111).zero?

  errors << "#{screenshot} must not be executable"
end

asset_files = Dir.glob(['**/*.blend', '**/*.unitypackage', '**/*.fbx', '**/*.FBX', '**/*.tga']).select { |path| File.file?(path) }.sort
asset_files.each do |asset|
  next if (File.stat(asset).mode & 0o111).zero?

  errors << "#{asset} must not be executable"
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

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Tutorial asset check passed for #{tutorials.length} tutorials."
