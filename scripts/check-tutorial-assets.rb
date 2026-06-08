#!/usr/bin/env ruby
# frozen_string_literal: true

errors = []
tutorials = Dir.glob('[0-9][0-9][0-9]_*').select { |path| File.directory?(path) }.sort

def require_file(errors, path, message)
  errors << message unless File.file?(path)
end

tutorials.each do |tutorial|
  readme = File.join(tutorial, 'README.md')
  require_file(errors, readme, "#{tutorial} is missing README.md")
  next unless File.file?(readme)

  content = File.read(readme)
  image_tags = content.scan(/<img\b[^>]*>/i)

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
    errors << "#{readme} references missing image #{src}" unless File.file?(target)
  end
end

require_file(errors, '001_collisions/ProjectSettings/ProjectVersion.txt', '001_collisions is missing Unity ProjectVersion.txt')
require_file(errors, '001_collisions/Assets/Scenes/PokemonThrow.unity', '001_collisions is missing PokemonThrow.unity')
require_file(errors, '002_characters/Pikachu.blend', '002_characters is missing Pikachu.blend')
require_file(errors, '002_characters/Pokeball.blend', '002_characters is missing Pokeball.blend')
require_file(errors, '003_augmented_reality/AR Example Pokemon Go/ProjectSettings/ProjectVersion.txt', '003_augmented_reality is missing Unity ProjectVersion.txt')
require_file(errors, '003_augmented_reality/AR Example Pokemon Go/Assets/Scenes/PokemonScene.unity', '003_augmented_reality is missing PokemonScene.unity')
require_file(errors, '004_slippy_maps/PokemonMap.unitypackage', '004_slippy_maps is missing PokemonMap.unitypackage')
require_file(errors, 'ASSET_NOTICES.md', 'ASSET_NOTICES.md is missing')
require_file(errors, 'docs/plans/2026-06-08-asset-notices-baseline.md', 'canonical docs/plans asset notice plan is missing')
require_file(errors, 'TOOLCHAIN.md', 'TOOLCHAIN.md is missing')

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

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Tutorial asset check passed for #{tutorials.length} tutorials."
