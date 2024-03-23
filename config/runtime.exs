previous_fun = Inspect.Opts.default_inspect_fun()

Inspect.Opts.default_inspect_fun(fn
  value, opts ->
    opts = Map.put(opts, :charlists, :as_lists)
    previous_fun.(value, opts)
end)
