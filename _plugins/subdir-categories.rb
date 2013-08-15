require "crochet"

Crochet::Hook.new(Jekyll::Post) do
	after :initialize do |post, site, source, dir, name|
		self.categories = (self.categories + name.split("/")[0...-1]).compact.uniq
	end
end
