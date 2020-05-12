defmodule Complex4 do

	def foo(x, id \\ 1) do
	  call_cnode({:foo, x}, id)
	end

	def bar(y, id \\ 1) do
	  call_cnode({:bar, y}, id)
	end

	def call_cnode(msg, id) do
		{:any, :'cnode#{id}@127.0.0.1'}
		|> send({:call, self(), msg})

	  receive do
	    {:cnode, result} ->
	      result
	    other ->
				IO.puts("other: #{inspect other} ")
		after
			2_000 ->
				IO.puts("timeout: ")
	  end
	end

end
