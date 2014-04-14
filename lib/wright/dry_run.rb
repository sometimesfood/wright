module Wright # rubocop:disable Documentation
  @dry_run = false

  # Public: Checks if dry-run mode is currently active.
  #
  # Examples
  #
  #   puts 'Just a dry-run...' if Wright.dry_run?
  #
  # Returns true if dry-run mode is currently active and false otherwise.
  def self.dry_run?
    @dry_run
  end

  # Public: Runs a block in dry-run mode.
  #
  # Examples
  #
  #   Wright.dry_run do
  #     symlink '/tmp/fstab' do |s|
  #       s.to = '/etc/fstab'
  #     end
  #   end
  #
  # Returns the block's return value.
  def self.dry_run
    saved_dry_run = @dry_run
    @dry_run = true
    yield
  ensure
    @dry_run = saved_dry_run
  end
end
