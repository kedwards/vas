# Molecule

Now, we can tell Molecule to create an instance with:

```
molecule create
```

We can verify that Molecule has created the instance and they’re up and running with:

```
molecule list
```

Now, let’s add a task to our tasks/main.yml like so:

```
- name: Molecule Hello World!
  debug:
    msg: Hello, World!
```

We can then tell Molecule to test our role against our instance with:

```
molecule converge
```

If we want to manually inspect the instance afterwards, we can run:

```
molecule login
```
We now have a free hand to experiment with the instance state.

Finally, we can exit the instance and destroy it with:

```
molecule destroy
```

Molecule provides commands for manually managing the lifecycle of the instance, scenario, development and testing tools. However, we can also tell Molecule to manage this automatically within a Scenario sequence.

The full lifecycle sequence can be invoked with:

```
molecule test
```

Note

It can be particularly useful to pass the --destroy=never flag when invoking molecule test so that you can tell Molecule to run the full sequence but not destroy the instance if one step fails.

