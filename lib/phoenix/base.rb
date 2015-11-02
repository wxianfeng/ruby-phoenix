#coding:utf-8
module Phoenix
  class Base
    include Common

    # 类变量meta_data 记录表的字段类型
    # [{:column_name=>"APP_ID", :column_type=>"UNSIGNED_INT"}, 
    #  {:column_name=>"ACCOUNT_ID", :column_type=>"VARCHAR"},  
    #  {:column_name=>"CREATE_DATE", :column_type=>"UNSIGNED_LONG"}] 
    def self.inherited(base)
      table_name = base.table_name
      meta = Phoenix::Rjb.get_meta_data(table_name)
      if meta.blank?
        raise "the phoenix table #{table_name} is Not Found!!!"
      end
      base.class_variable_set("@@meta_data", meta)

      meta.each do |row|
        base.send(:attr_accessor, row[:column_name])
      end
    end

  end
end
