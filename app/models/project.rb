class Project < ActiveRecord::Base  
  has_many :project_pictures, :dependent => :destroy do
    def primary_pic
      (self.select {|pic| pic.primary_picture }).first
    end
    
    def secondary_pics
      self.reject {|pic| pic.primary_picture }
    end
  end
  
  has_many :preview_pictures, :dependent => :destroy
  
  has_one :preview_picture
  
  named_scope :recent, :limit => 8, :order => 'created_at DESC'
  
  validates_presence_of :name
  validates_presence_of :description
  
  after_update :save_pictures
  
  def new_picture_attributes=(picture_attributes)
    picture_attributes.each do |attributes|
      project_pictures.build(attributes)
    end
  end
  
  def new_preview_picture_attributes=(preview_picture_attributes)
    preview_picture_attributes.each do |attributes|
      preview_pictures.build(attributes)
    end
  end
  
  def existing_picture_attributes=(picture_attributes)
    project_pictures.reject(&:new_record?).each do |picture|
      attributes = picture_attributes[picture.id.to_s]
      if attributes
        picture.attributes = attributes
      else
        project_pictures.destroy(picture)
      end
    end
  end
  
  def existing_preview_picture_attributes=(preview_picture_attributes)
    preview_pictures.reject(&:new_record?).each do |picture|
      attributes = preview_picture_attributes[picture.id.to_s]
      if attributes
        picture.attributes = attributes
      else
        preview_pictures.destroy(picture)
      end
    end
  end
  
  def save_pictures
    project_pictures.each do |picture|
      picture.save(false)
    end
    
    preview_pictures.each do |picture|
      picture.save(false)
    end
  end  
end
