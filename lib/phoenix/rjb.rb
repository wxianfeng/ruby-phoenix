#coding: utf-8
module Phoenix
  class Rjb

    def self.is_query?(s)
      s and !(s.strip =~ /^select/i).nil?
    end

    # 查询
    # return => Array [#<>, #<>, ...]
    # 更新(增加, 修改,删除)
    # return 1 成功, 0 失败
    def self.execute(sql)
      Rails.logger.info "[SQL]: #{sql}\n" if defined? Rails

      h = YAML.load(File.read "#{Rails.root}/config/phoenix.yml")
      host = h["host"]
      port = h["port"]

      c = ::Rjb::import('phoenix.Connect')
      instance = c.new(host, port)
      if self.is_query?(sql)
        rs = instance.executeQuery(sql)
        if rs.nil?
          arr = []
        else
          arr = resultset_to_obj(rs)
        end
        instance.close()
        return arr
      else
        i = instance.executeUpdate(sql)
        # p i.methods - Object.methods
        # p i.intValue
        instance.close()
        return i.intValue
      end
    end

    def self.get_meta_data(table_name)
      c = ::Rjb::import('phoenix.Connect')

      h = YAML.load(File.read "#{Rails.root}/config/phoenix.yml")
      host = h["host"]
      port = h["port"]

      instance = c.new(host, port)
      rs = instance.getMetaData(table_name)
      # binding.pry
      # rs.java_methods
      arr = resultset_to_meta(rs)
      instance.close()
      $stdout.print "[MetaData:#{table_name}]: #{arr.inspect}\n"
      return arr
    end

    def self.resultset_to_meta(resultset)
      columns = []
      while resultset.next
        column_name = resultset.getString("COLUMN_NAME")
        column_type = resultset.getString("TYPE_NAME")
        columns << { column_name: column_name, column_type: column_type }
      end
      return columns
    end

    # 把 Java 中的 ResultSet对象 转化为 Ruby 中的 对象
    # https://gist.github.com/rjackson/1366047
    def self.resultset_to_obj(resultset)
      meta = resultset.meta_data
      table_name = meta.table_name(1)
      if table_name == "BASE_SINDEX"
        table_name = "BASE"
      end
      rows = []

      while resultset.next
        row = {}
        (1..meta.column_count).each do |i|
          name = meta.column_name i
          row[name]  =  case meta.column_type(i)
                        when -6, -5, 5, 4
                          # TINYINT, BIGINT, INTEGER
                          resultset.getLong(i).to_i
                        when 41
                          # Date
                          resultset.getDate(i)
                        when 92
                          # Time
                          resultset.getTime(i).to_i
                        when 93
                          # Timestamp
                          resultset.getTimestamp(i)
                        when 2, 3, 6
                          # NUMERIC, DECIMAL, FLOAT
                          case meta.scale(i)
                          when 0
                            resultset.getLong(i).to_i
                          else
                            BigDecimal.new(resultset.getString(i).to_s)
                          end
                        when 1, -15, -9, 12
                          # CHAR, NCHAR, NVARCHAR, VARCHAR
                          resultset.getString(i).to_s
                        else
                          resultset.getString(i).to_s
                        end
        end

        begin
          rows << table_name.downcase.camelize.constantize.new(row)
        rescue NameError
          raise "[Error] Missing #{table_name.downcase.camelize} Model, pls define it\n"
        end  
      end
      rows
    end

  end
end
