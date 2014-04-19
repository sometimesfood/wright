require 'minitest/autorun'
require 'minitest/mock'

require 'open3'

FakeProcessStatus = Struct.new(:success?)

def command_output(command_filename)
  command_stdout = File.read("#{APT_DIR}/#{command_filename}.stdout")
  command_stderr = File.read("#{APT_DIR}/#{command_filename}.stderr")
  command_status = File.read("#{APT_DIR}/#{command_filename}.return") == '0'
  [ command_stdout, command_stderr, command_status ]
end

APT_DIR = File.join(File.dirname(__FILE__), 'apt')

CAPTURE3 = {
  'dpkg-query -s htop' => command_output('dpkg-query.htop'),
  'dpkg-query -s vlc' => command_output('dpkg-query.vlc')
}

describe 'something' do
  before :each do
    @mock_open3 = Minitest::Mock.new
    @capture3_stub = ->(command) { @mock_open3.capture3(command) }
  end

  it 'should do something' do
    command = 'dpkg-query -s htop'
    @mock_open3.expect(:capture3, CAPTURE3[command], [command])

    Open3.stub :capture3, @capture3_stub do
      stdout, stderr, status = Open3.capture3('dpkg-query -s htop')
      stdout.must_equal command_output('dpkg-query.htop')[0]
    end
  end
end
