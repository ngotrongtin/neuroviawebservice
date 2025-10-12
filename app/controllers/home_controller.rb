class HomeController < ApplicationController
    layout "blank", only: [:contact]
    def index
              
    end

    def contact
              
    end

    def document
        render template: "document/index"
    end
end