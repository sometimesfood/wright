module Wright # rubocop:disable Documentation
  @dry_run = false

  # Checks if dry-run mode is currently active.
  #
  # @example
  #   puts 'Just a dry-run...' if Wright.dry_run?
  #
  # @return [Bool] true if dry-run mode is currently active and false
  #   otherwise
  def self.dry_run?
    @dry_run
  end

  # Runs a block in dry-run mode.
  #
  # @example
  #   Wright.dry_run do
  #     symlink '/tmp/fstab' do |s|
  #       s.to = '/etc/fstab'
  #     end
  #   end
  #
  # @return the block's return value
  def self.dry_run
    saved_dry_run = @dry_run
    @dry_run = true
    yield
  ensure
    @dry_run = saved_dry_run
  end
end
