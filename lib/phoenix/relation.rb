#coding:utf-8
module Phoenix
  class Relation

    attr_accessor :sql

    def initialize(sql)
      @sql = sql
    end

    def limit(size)
      if size.to_i > 0
        self.sql << " LIMIT #{size}"
      end
      self
    end

    def order(o)
      self.sql << " ORDER BY #{o}"
      self
    end

    def take
      Phoenix::Rjb.execute(@sql)
    end

    def where(str)
      self.sql << str if str.present?
      self
    end

    def to_sql
      self.sql
    end

  end
end
