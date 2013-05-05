require 'open3'

desc "Run coffeelint"
task :lint do
  Open3.popen3("coffeelint", "-r", "spec", "app") do |i, o, e, t|
    print o.readlines.join()
    if t.value.exitstatus != 0
      fail "Not lint free!"
    end
  end
end
