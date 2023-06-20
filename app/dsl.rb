class Object
  def debug # show ivars of objects when inspecting
    ivars = instance_variables.map do |attribute|
      { attribute => instance_variable_get(attribute) }
    end

    puts "<#{self.class.name} #{ivars}>"
  end
end

module Forking
  class Story
    def self.instance
      @_story ||= new
    end

    def initialize
      @locations = []
    end

    def read(&block)
      instance_eval(&block) if block
    end

    def title(title)
      @title = title
    end

    def location(id, &block)
      location = Location.new(id)
      location.read(&block) if block
      @locations << location
    end

    def compile
      $gtk.args.state.locations = @locations
      {
        title: @title,
        content: @locations.map(&:compile)
      }
    end

    def inspect
      compile
    end
  end

  class Location
    def initialize(id)
      @id = id
      @title = ""
      @paragraphs = []
      @choices = []
    end

    def read(&block)
      instance_eval(&block)
    end

    def heading(heading)
      @heading = heading
    end

    def choice(title, destination)
      @choices << {choice: title, destination: destination}
    end

    def p(paragraph)
      @paragraphs << paragraph
    end

    def compile
      {
        id: @id,
        heading: @title,
        description: @paragraphs.join("\n\n"),
        choices: @choices
      }
    end
  end

  def self.story(&block)
    s = Forking::Story.instance
    s.read(&block)
    s
  end
end
