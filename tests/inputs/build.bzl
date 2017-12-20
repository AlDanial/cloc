"""This example creates a rule with a declared output."""

def _impl(ctx):
  ctx.actions.write(
      # Access the default outputs using ctx.outputs.<output name>.
      output=ctx.outputs.my_output,
      content="Hello World!"
  )
  # The default outputs are added automatically to this target.

rule_with_outputs = rule(
    implementation=_impl,
    outputs = {
        # %{name} is substituted with the rule's name
        "my_output": "%{name}.txt"
    }
)

