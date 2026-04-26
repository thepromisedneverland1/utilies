request(
	{
		Url = "", 
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = {["content"] = "not tuff"}
	}	 
)
game:HttpGet("")
request(	
	{
		Url = "https://support.github.com/", 
		Method = "GET",
	}	
)
game:HttpGet("")
