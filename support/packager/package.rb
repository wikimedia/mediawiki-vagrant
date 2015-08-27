#!/usr/bin/env ruby

require 'digest'
require 'fileutils'
require 'net/http'
require 'pathname'
require 'yaml'

include FileUtils

$packager_dir = Pathname.new(__FILE__).parent.realpath
$output_dir = $packager_dir + 'output'
$contents_dir = $output_dir + 'contents'
$iso_file = $output_dir + 'mediawiki-vagrant-installer.iso'

$url_config = YAML.load(($packager_dir + 'urls.yaml').read)

# TODO (mattflaschen, 2014-04-30): Symbolic links might be nice, but
# not sure if there's a USB filesystem (NTFS?) that supports symlinks
# reliably and works cross-OS.

# TODO (mattflaschen, 2014-04-30): Should it automatically find and
# download the latest file for each installer?

$sha256 = Digest::SHA256.new

# Checks the SHA256.  If it matches, doesn't need to be downloaded again
def download_file(target_dir_pathname, url_info)
  url = url_info['url']

  filename = target_dir_pathname;
  if url_info.key?('filename')
    filename += url_info['filename']
  else
    # Use the initial URL's basename, rather than following redirects
    # first, since one of them redirects to a URL with a long unreadable
    # basename.
    filename += Pathname.new(url).basename
  end

  puts "Checking #{filename}..."
  if filename.exist? && url_info.include?('sha256')
    $sha256.reset
    $sha256.file(filename)
    if $sha256.hexdigest === url_info['sha256']
      puts "File '#{filename}' up to date."
      return
    else
      puts "File '#{filename}' exists, but the hash did not match.  Re-downloading."
    end
  end

  target_dir_pathname.mkpath
  download_file_to_filename(filename, url)
end

# Based on http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net.html#label-Streaming+Response+Bodies
# Not sure if there's a simpler way to do this without reading the whole file into memory.
def download_file_to_filename(filename, url)
  puts "Downloading #{url}..."
  uri = URI(url)

  Net::HTTP.start(
      uri.host,
      uri.port,
      :use_ssl => uri.scheme == 'https'
  ) do |http|
    request = Net::HTTP::Get.new uri.request_uri

    http.request request do |response|
      if response.is_a?(Net::HTTPRedirection) || response.is_a?(Net::HTTPFound)
        return download_file_to_filename(filename, response['location'])
      end

      open filename, 'wb' do |io|
        response.read_body do |chunk|
          io.write(chunk)
        end
      end
    end
  end
end

def common()
  old_cwd = Dir.pwd

  mkdir_p($contents_dir)

  download_file($contents_dir, $url_config['Base Box'])

  mediawiki_vagrant_dir = $packager_dir.parent.parent
  core_dir = mediawiki_vagrant_dir + 'mediawiki'

  Dir.chdir(mediawiki_vagrant_dir)
  puts 'Creating git bundle for mediawiki-vagrant...'
  system('git', 'bundle', 'create', ($contents_dir + 'mediawiki_vagrant.bundle').to_s, 'master')

  Dir.chdir(core_dir)
  puts 'Creating git bundle for mediawiki-core...'
  system('git', 'bundle', 'create', ($contents_dir + 'mediawiki_core.bundle').to_s, 'master')

  Dir.chdir(mediawiki_vagrant_dir)
  puts 'Copying cache...'
  system('cp', '-R', 'cache', $contents_dir.to_s)

  Dir.chdir(old_cwd)

  download_file($contents_dir, $url_config['GPLv2'])
  download_file($contents_dir, $url_config['Vagrant License'])

  plugins_dir = $contents_dir + 'Plugins'
  $url_config['Vagrant']['Plugins'].each do |_plugin, url|
    download_file(plugins_dir, url)
  end

  template = $packager_dir + 'template'
  puts 'Copying template files...'
  cp(template + 'README.txt', $contents_dir)
  cp(template + 'LICENSE', $contents_dir)
end

def linux()
  linux_dir = $contents_dir + 'Linux'

  $url_config['VirtualBox']['Linux'].each do |distro, url|
    distro_dir = linux_dir + distro
    download_file(distro_dir, url)
  end

  $url_config['Vagrant']['Linux'].each do |format, url|
    vagrant_format_dir = linux_dir + format
    download_file(vagrant_format_dir, url)
  end
end

def mac()
  mac_dir = $contents_dir + 'Mac'
  download_file(mac_dir, $url_config['VirtualBox']['Mac'])
  download_file(mac_dir, $url_config['Vagrant']['Mac'])
  download_file(mac_dir, $url_config['Git']['Mac'])
end

def windows()
  windows_dir = $contents_dir + 'Windows'
  download_file(windows_dir, $url_config['VirtualBox']['Windows'])
  download_file(windows_dir, $url_config['Vagrant']['Windows'])
  download_file(windows_dir, $url_config['Git']['Windows'])
end

def build_iso()
  puts 'Creating iso image to distribute...'
  # -r: Rock Ridge with recommended values for permissions, etc.
  if system('which genisoimage >/dev/null 2>&1')
    system('genisoimage', '-r', '-o', $iso_file.to_s, $contents_dir.to_s)
  else
    puts '"genisoimage" not found. Iso image not created.'
  end
end

common
linux
mac
windows
build_iso
