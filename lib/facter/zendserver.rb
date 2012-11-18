Facter.add(:zendserver) do
	confine :kernel => :linux
	setcode do
		if FileTest.exists?("/usr/local/zend/bin/php")
			"true"
		else
			"false"
		end
	end
end

