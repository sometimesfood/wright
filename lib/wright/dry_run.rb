module Wright
  @dry_run = false

  def self.dry_run?
    @dry_run
  end

  def self.dry_run
    saved_dry_run = @dry_run
    @dry_run = true
    yield
  ensure
    @dry_run = saved_dry_run
  end
end
