require 'mail'

class Mailer

  def self.send(from:, to:, password:, report:)
    options = {
      address:              'smtp.gmail.com',
      port:                 587,
      user_name:            from,
      password:             password,
      authentication:       'plain',
      enable_starttls_auto: true
    }
    Mail.defaults do
      delivery_method :smtp, options
    end
    Mail.deliver do
      to to
      from from
      subject Mailer.subject(report)
      body Mailer.body(report)
    end
  end

  private

  def self.body(report)
    b = []
    report.each do |k, data|
      s = ''
      if data[:error]
        s << "❌ #{k}\n"
        s << '=' * 80 << "\n"
        s << "Backup FAILED!\n"
        s << "  error: #{data[:error]}\n"
        b << s
      else
        s << "️✅ #{k}\n"
        s << '=' * 80 << "\n"
        s << "Backup SUCCESS!\n"
        s << "  dump size: #{data[:size]} MB\n"
        s << "  time: #{data[:time]} seconds\n"
        s << "  dump saved in: #{data[:path]}\n"
        if data[:extra_copy]
          s << "  extra copy in: #{data[:extra_copy]}\n"
        else
          s << "  no extra copy has been made\n"
        end
        b << s
      end    
    end
    return "Report for backups (#{Time.now})\n\n#{b.join("\n\n")}"
  end

  def self.subject(report)
    errors = report.select{|k, v| v[:error]}.size
    icon = '✅'
    icon = '⚠️' if errors > 0
    icon = '❌' if errors == report.size
    return "[Backupper] #{report.size-errors}/#{report.size} backups successfully completed #{icon}"
  end

end