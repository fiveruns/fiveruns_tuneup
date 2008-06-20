module Fiveruns::Tuneup::Model
   def self.record(model, name, raw_sql=nil, &operation)
     sql = nil
     Fiveruns::Tuneup.exclude do
       model.silence do
         sql = Fiveruns::Tuneup::Step::SQL.new(raw_sql, model.connection) if raw_sql
         Fiveruns::Tuneup.add_schema_for(model.table_name, model.connection)
       end
     end
     Fiveruns::Tuneup.step(name, :model, true, sql, model.table_name, &operation)
   end
end

instrumenting 'ActiveRecord::Base', :class do     
  def find_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Find #{self.name}" do
      find_without_fiveruns_tuneup(*args, &block)
    end
  end
  def find_by_sql_with_fiveruns_tuneup(conditions, &block)
    Fiveruns::Tuneup::Model.record self, "Find #{self.name} by SQL", sanitize_sql(conditions) do
      find_by_sql_without_fiveruns_tuneup(conditions, &block)
    end
  end
  def create_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Create #{self.name}" do
      create_without_fiveruns_tuneup(*args, &block)
    end
  end
  def update_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Update #{self.name}" do
      update_without_fiveruns_tuneup(*args, &block)
    end
  end
  def update_all_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Update #{self.name} (All)" do
      update_all_without_fiveruns_tuneup(*args, &block)
    end
  end
  def destroy_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Destroy #{self.name}" do
      destroy_without_fiveruns_tuneup(*args, &block)
    end
  end
  def destroy_all_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Destroy #{self.name} (All)" do
      destroy_all_without_fiveruns_tuneup(*args, &block)
    end
  end
  def delete_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Delete #{self.name}" do
      delete_without_fiveruns_tuneup(*args, &block)
    end
  end
  def delete_all_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self, "Delete #{self.name} (All)" do
      delete_all_without_fiveruns_tuneup(*args, &block)
    end
  end
end

instrumenting 'ActiveRecord::Base', :instance do
  def update_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self.class, "Update #{self.class.name}" do
      update_without_fiveruns_tuneup(*args, &block)
    end
  end
  def save_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self.class, "Save #{self.class.name}" do
      save_without_fiveruns_tuneup(*args, &block)
    end
  end
  def save_with_fiveruns_tuneup!(*args, &block)
    Fiveruns::Tuneup::Model.record self.class, "Save #{self.class.name}" do
      save_without_fiveruns_tuneup!(*args, &block)
    end
  end
  def destroy_with_fiveruns_tuneup(*args, &block)
    Fiveruns::Tuneup::Model.record self.class, "Destroy #{self.class.name}" do
      destroy_without_fiveruns_tuneup(*args, &block)
    end
  end
end
