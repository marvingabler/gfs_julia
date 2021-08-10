module Api

using Genie, Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = Api))

  Genie.genie(; context = @__MODULE__)

  Base.eval(Main, :(const Genie = Api.Genie))
  Base.eval(Main, :(using Genie))
end

end
