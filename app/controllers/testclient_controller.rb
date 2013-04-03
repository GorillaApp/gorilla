class TestclientController < ApplicationController
    before_filter :authenticate_user!
    def client
    end
end
