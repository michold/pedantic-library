require 'bundler/setup' 
Bundler.require

DEFAULT_LOCATION = '/Users/poiu/Desktop/'
CWD = ARGV[0] || DEFAULT_LOCATION

def main
  Dir.chdir CWD
  Dir.entries('./').each do |dir|
    next if skip_dir?(dir)
    puts dir
  end
end

def skip_dir?(dir)
  recursive?(dir) || file?(dir) || !has_music?(dir)
end

def recursive?(dir)
  dir == '.' || dir == '..'
end

def file?(dir)
  File.file? dir
end

def has_music?(dir)
  # Dir.glob("**/*")
end

main