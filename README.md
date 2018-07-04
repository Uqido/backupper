# Backupper

Backupper is a useful tool to backup all your databases spreaded in the world!

## Installation

    $ gem install backupper

## Usage

    $ backupper path/to/config.yml

## Configuration file

A common config file for backupper looks like this:

```yaml
mailer:
  from: support@email.com # Gmail account used to send report email
  to: pioz@email.com      # Send report email to this address
  password: Pa$$w0rD      # Gmail account password

db1:
  disabled: false                              # true to disable this backup
  dump: '/home/backup/db1'                     # path where to save the dump of the database
  extra_copy: '/mnt/backup-disk/backups/db1'   # path where to save a extra copy of the dump
  username: user                               # server ssh username
  host: '1.2.3.4'                              # server ssh ip
  port: 22                                     # server ssh port
  password: Pa$$w0rD                           # server ssh password
  adapter: mysql                               # database to backup (supported are mysql or postgresql)
  database: db_name                            # database name
  db_username: db_user                         # database username
  db_password: db_Pa$$w0rD                     # database password
  dump_options: '--single-transaction --quick' # dump command extra options

db2:
  disabled: false
  dump: '/home/backup/db2'
  extra_copy: '/mnt/backup-disk/backups/db2'
  username: user
  host: '1.2.3.4'
  port: 22
  password: Pa$$w0rD
  adapter: postgresql
  database: db_name
  db_username: db_user
  db_password: db_Pa$$w0rD
```

After done all backups a report email is sent to you using gmail smtp service (remember to permit less secure app [here](https://myaccount.google.com/lesssecureapps)).

⚠️ __WARNING__: the backupper configuration file contains many important passwords, so be careful to lock it and protect it with care!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/uqido/backupper.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Uqido

[![uqido](https://i.imgur.com/FAo2W7w.png)](http://uqido.com)

Backupper is maintained and funded by [Uqido](https://uqido.com).
The names and logos for Uqido are trademarks of Uqido s.r.l.

The [Uqido team](https://www.uqido.com/chi-siamo/).