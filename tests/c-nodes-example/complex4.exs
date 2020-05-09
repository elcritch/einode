defmodule Complex4 do

	def foo(x) do
	  call_cnode({:foo, x})
	end

	def bar(y) do
	  call_cnode({:bar, y})
	end

	def call_cnode(msg) do
		{:any, :'cnode@127.0.0.1'}
		|> send({:call, self(), msg})

	  receive do
	    {:cnode, result} ->
	      result
	    other ->
	      IO.puts("other: #{inspect other} ")
	  end
	end

end
