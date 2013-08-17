require "crochet"

Crochet::Hook.new(Jekyll::Post) do
    before :url do
        if slug == "index" and !@url
            @url = "."
        end
    end
end
