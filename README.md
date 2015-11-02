# ruby-phoenix
Ruby Client To Run SQL Of Apache Phoenix.

## Install 
```
Gemfile
gem 'ruby-phoenix', require: 'phoenix'
```

## Config
```
1, Install Java jar file
rake phoenix:install
2, config Hbase host and port
vi config/phoenix.yml
```

## Usage
```
1, define Model
class StYunosAppCenterCntNew < Phoenix::Base
end

2.1, Run SQL
sql = "select * from ST_YUNOS_APP_CENTER_CNT_NEW limit 10"
results = Phoenix::Rjb.execute(sql)

2.2, OR Use Model Like ActiveRecord
StYunosAppCenterCntNew.all
```

That's ALL, Enjoy It!!!
