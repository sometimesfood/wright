require 'minitest/mock'
require 'open3'

# Open3::capture3 replacement that reads stdout, stderr and return
# values from the filesystem
class FakeCapture3
  def initialize(basedir, env = {})
    @basedir = basedir
    @env = env
    @mock_open3 = Minitest::Mock.new
    @capture3_stub = lambda do |stub_env, stub_command, *stub_args|
      @mock_open3.capture3(stub_env, stub_command, *stub_args)
    end
  end

  def expect(command_and_args, base_filename = nil)
    command, *args = *command_and_args
    @mock_open3.expect(:capture3,
                       return_values(command_and_args, base_filename),
                       [@env, command, *args])
  end

  def stub
    Open3.stub :capture3, @capture3_stub do
      yield if block_given?
    end
    @mock_open3.verify
  end

  private

  def return_values(command_and_args, base_filename)
    filename = base_filename ||
               command_and_args.join(' ').tr(' ', '_').gsub('/', 'SLASH')
    command_stdout = File.read("#{@basedir}/#{filename}.stdout")
    command_stderr = File.read("#{@basedir}/#{filename}.stderr")
    command_status = File.read("#{@basedir}/#{filename}.return").chomp == '0'
    [command_stdout, command_stderr, FakeProcessStatus.new(command_status)]
  end

  # fake Process::Status replacement
  class FakeProcessStatus
    def initialize(success)
      @success = success
    end

    def success?
      @success
    end
  end
end
