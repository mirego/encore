module ModelMacros
  # Create a new ActiveRecord model
  def spawn_model(klass_name, options = {}, &block)
    spawn_object klass_name, ActiveRecord::Base do
      instance_exec(&block) if block
    end
  end

  # Create a new Encore::Serializer object
  def spawn_serializer(klass_name, options = {}, &block)
    spawn_object klass_name, Encore::Serializer::Base do
      instance_exec(&block) if block
    end
  end

  protected

  # Create a new model class
  def spawn_object(klass_name, parent_klass, &block)
    Object.instance_eval { remove_const klass_name } if Object.const_defined?(klass_name)
    Object.const_set(klass_name, Class.new(parent_klass))
    Object.const_get(klass_name).class_eval(&block) if block_given?
  end
end
