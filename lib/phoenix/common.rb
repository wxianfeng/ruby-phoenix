#coding:utf-8
module Phoenix
  module Common
    extend ActiveSupport::Concern

    module Status
      Normal = 0
      Forbid = 1
    end

    module ClassMethods

      def first
        sql = "select * from #{self.table_name} limit 1"
        Phoenix::Rjb.execute(sql)[0]
      end

      def select(*fields)
        sql = "SELECT #{fields.join(', ')} FROM #{table_name}"
        Phoenix::Rjb.execute(sql)
      end

      def quote(s)
        return s if s.blank?
        return s if s.is_a? Integer
        "'#{s.gsub(/\\/, '\&\&').gsub(/'/, "''")}'"
      end

      def in_cond(arr)
        arr.map { |_v| self.quote(_v) }.join(',')
      end

      def is_int_column?(column)
        meta = self.class_variable_get("@@meta_data")
        if meta.blank?
          table_name = self.table_name
          meta = Phoenix::Rjb.get_meta_data(table_name)
          self.class_variable_set("@@meta_data", meta)
        end
        type = meta.select { |ele| ele[:column_name] == column.to_s.upcase }.first[:column_type]
        if type =~ /int|long/i
          return true
        end
        return false
      end

      def table_name
        last_3_letter = self.to_s[-3..-1]
        if last_3_letter.downcase == 'new'
          return self.to_s.tableize.singularize.upcase[0..-2]
        else
          return self.to_s.tableize.singularize.upcase
        end
      end

      def associate_table_name(klass)
        case klass
        when "Base"
          "BASE"
        else
          klass.tableize.singularize
        end
      end

      def find(id)
        column = "#{self.to_s}_ID"
        unless self.is_int_column?(column)
          id = self.quote(id)
        end
        
        sql = "SELECT * FROM #{self.to_s} WHERE #{column} = #{id}"

        digest = Digest::MD5.hexdigest(sql)

        Datacraft::Cache.get digest do
          arr = Phoenix::Rjb.execute(sql)  
          arr.first
        end
      end

      def find_by_sql(sql)
        Phoenix::Rjb.execute(sql)
      end

      def all
        sql = "SELECT * FROM #{self.table_name}"
        Phoenix::Rjb.execute(sql)
      end

      ##
      # 组装 sql
      # Hash
      #   Model.where(field1: value1, field2: value2)
      # String
      #   Model.where('field1 = value1 AND field2 = value2')
      # Blank
      #   Model.where() / Model.where('')
      def where(*args)
        table_name = self.table_name
        if args.all? { |ele| ele.blank? }
          sql = %(SELECT * FROM #{table_name})
          return Relation.new(sql)
        end
        if args.size < 2 and args[0].is_a? String
          sql = %(SELECT * FROM #{table_name} WHERE #{args[0]})
          return Relation.new(sql)
        end
        options = args.extract_options!
        cond = ""
        options.each_with_index do |(k,v), index|
          if index > 0
            if v.is_a? Array
              cond << " AND #{k} IN " + " (#{v.map { |_v| self.quote(_v) }.join(',')})"
            else
              if self.is_int_column? k
                cond << " AND #{k} = #{v} "
              else
                cond << " AND #{k} = '#{v}' "
              end
            end
          else
            if v.is_a? Array
              cond << " #{k} IN " + " (#{v.map { |_v| self.quote(_v) }.join(',')})"
            else
              if self.is_int_column?(k)
                cond << " #{k} = #{v} "
              else
                cond << " #{k} = '#{v}' "
              end
            end
          end
        end
        sql = %(SELECT * FROM #{table_name} WHERE #{cond})
        Relation.new(sql)
      end

      def build(h)
        self.new(h)
      end

      def belongs_to(t)
        self.class_eval do
          define_method t do
            key = "#{t.upcase}_ID"
            sql = %(SELECT * FROM #{t.upcase} WHERE APP_ID = '#{self.APP_ID}' AND #{key} = '#{self.send(key)}')
            digest = Digest::MD5.hexdigest(sql)
            Datacraft::Cache.get digest do
              arr = Phoenix::Rjb.execute(sql)
              arr.first
            end
          end
        end
      end

      def has_many(*args)
        t = args[0].to_s
        options = args.extract_options!
        self.class_eval do
          define_method t do
            if options[:through]
              key = "#{self.class.to_s.upcase}_ID"
              assoite_sql = %(SELECT * FROM #{options[:through]} WHERE APP_ID = '#{self.APP_ID}' AND #{key} = '#{self.send(key)}')
              assoite_rs = Phoenix::Rjb.execute(assoite_sql)
              assoite_key = "#{t.singularize.upcase}_ID"
              ids = assoite_rs.collect { |ass| ass.send("#{assoite_key}") }
              if ids.present?
                sql = %(SELECT * FROM #{t.singularize} WHERE APP_ID = '#{self.APP_ID}' AND #{assoite_key} IN (#{ids.map { |_v| self.class.quote(_v) }.join(',')}))
                Phoenix::Rjb.execute(sql)
              else
                []
              end
            else
              # table = "#{t[0..-2]}"
              table = self.class.associate_table_name(t.singularize)
              key = "#{self.class.to_s.upcase}_ID"
              v = self.send(key)
              unless self.class.is_int_column?(key)
                v = self.class.quote(v)
              end
              sql = %(SELECT * FROM #{table} WHERE #{key} = #{v})
              Phoenix::Rjb.execute(sql)
            end
          end
        end
      end

    end

    def initialize(h)
      return self if h.blank?
      h.each do |k, v|
        if self.respond_to? "#{k}="
          self.send("#{k}=", v)
        elsif k =~ /SequenceValueExpression/
          self.instance_variable_set("@next_value", v)
        else
          self.instance_variable_set("@#{k[/\w+/]}", v)
        end
      end
      return self
    end

    def human_status
      self.STATUS == '1' ? "禁用" : "正常"
    end

    def human_create_date
      Time.at(self.CREATE_DATE.to_i/1000).strftime("%Y-%m-%d %H:%M:%S")
    end

    def error
      self.errors.values.join("<br/>")
    end

  end
end
