# Step 4: separate symptom from cause

Seeing a symptom is not the same as knowing why it happens. Before you write down a
cause (in a comment, a changelog, or an upstream issue), **observe the mechanism**:
print what the failing consumer actually sees (its references, inputs, resolved
config), then change that one thing and watch the symptom follow it. A difference
you find nearby is a lead, not a cause.

Probe tools have versions too. A probe on an older compiler or SDK can create its own
red. Run every probe on NEW as a control: a probe that is red on both versions proves
nothing.

Done when every stated cause has a direct observation behind it, or is labelled as
a guess.
