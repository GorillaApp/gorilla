require 'open3'

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end

desc "Run coffeelint"
task :my_coffeelint do
  if which('coffeelint').nil?
    puts "You need to install coffeelint"
  else
    Open3.popen3("coffeelint", "-r", "spec", "app") do |i, o, e, t|
      puts o.readlines.join()
      if t.value.exitstatus != 0
        fail "Not lint free!"
      end
    end
  end
end
