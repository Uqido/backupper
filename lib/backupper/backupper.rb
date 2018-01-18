require 'yaml'
require 'fileutils'
require 'sshkit'
require 'sshkit/dsl'
include SSHKit::DSL

class Backupper

  SSHKit::Backend::Netssh.configure do |ssh|
    ssh.connection_timeout = 30
    ssh.ssh_options = {
      auth_methods: %w(publickey password)
    }
  end

  def initialize(conf_file_path)
    conf = YAML.load_file(conf_file_path)
    @default = conf['default'] || {}
    @mailer = conf['mailer'] || {}
    @conf = conf.select{|k, v| !%w(default mailer).include?(k) && (v['disabled'].nil? || v['disabled'] == false)}
    @report = {}
  end

  def backup!
    @conf.each do |k, options|
      o = @default.merge(options)
      puts "🗄 run backup of #{k}..."
      outdir = check_dir(o['dump'].to_s)
      unless outdir
        err = 'Invalid directory where to save database dump'
        error(k, err)
        puts err
        next
      end
      host = o['host']
      host = "#{o['username']}@#{host}" if o['username']
      host = "#{host}:#{o['port']}" if o['port']
      adapter = o['adapter'] || 'mysql'
      unless self.respond_to?("#{adapter}_dump_command")
        err = "Cannot handle adapter '#{adapter}'"
        error(k, err)
        puts err
        next
      end
      unless o['database']
        err = 'Please specify database name!'
        error(k, err)
        puts err
        next
      end
      begin
        download_dump(
          key: k,
          adapter: adapter,
          host: host,
          password: o['password'],
          database: o['database'],
          db_username: o['db_username'],
          db_password: o['db_password'],
          outdir: outdir,
          extra_copy: o['extra_copy']
        )
      rescue SSHKit::Runner::ExecuteError => e
        error(k, e.to_s)
        puts e
      end
    end
    if @report.any? && @mailer['from'] && @mailer['to'] && @mailer['password']
      begin
        Mailer.send(from: @mailer['from'], to: @mailer['to'], password: @mailer['password'], report: @report)
      rescue Net::SMTPAuthenticationError => e
        puts e
      end
    end
  end

  def mysql_dump_command(database:, username: 'root', password: nil, outfile:)
    params = []
    params << "--databases '#{database}'"
    params << "-u#{username}"
    params << "-p#{password}" if password
    return "mysqldump #{params.join(' ')} | bzip2 > '#{outfile}'"
  end

  def postgresql_dump_command(database:, username: 'root', password: nil, outfile:)
    params = []
    params << "-U #{username}"
    params << "-W #{password}" if password
    params << "'#{database}'"
    return "pg_dump #{params.join(' ')} | bzip2 > '#{outfile}'"
  end

  def download_dump(key:, adapter: 'mysql', host:, password: nil, database:, db_username: 'root', db_password: nil, outdir:, extra_copy: nil)
    if self.respond_to?("#{adapter}_dump_command")
      t = Time.now
      path = nil
      dump_name = nil
      filename = "#{key}__#{database}.sql.bz2"
      tempfile = File.join('/tmp', filename)
      dumpname = "#{Time.now.strftime('%Y-%M-%d_%H-%M-%S')}__#{filename}"
      path = File.join(outdir, dumpname)
      backupper = self
      on(host) do |host|
        host.password = password
        execute backupper.send("#{adapter}_dump_command", database: database, username: db_username, password: db_password, outfile: tempfile)
        download! tempfile, path
        execute :rm, tempfile
      end
      extra_copy = check_dir(extra_copy)
      FileUtils.cp(path, extra_copy) if extra_copy
      @report[key] = {
        path: File.absolute_path(path),
        size: (File.size(path).to_f / 2**20).round(2),
        time: (Time.now - t).round(2)
      }
      @report[key].merge!({extra_copy: File.absolute_path(File.join(extra_copy, dumpname))}) if extra_copy
    end
  end

  private

  def error(key, error)
    @report[key] = {error: error}
  end

  def check_dir(dirpath)
    return nil if dirpath.nil?
    unless File.exists?(dirpath)
      begin
        FileUtils::mkdir_p(dirpath)
      rescue => e
        return nil
      end
    end
    return File.dirname(dirpath) unless File.directory?(dirpath)
    return dirpath
  end

end