Auto
====

Automate everything!

Notice
------

This gem is currently under development. Some of what you see below is a fantasy.

Install
-------

<pre>
sudo gem install auto --source http://gemcutter.org
</pre>

Introduction
------------

Auto is a framework for writing automation scripts and plugins for those scripts.

<pre>
require 'rubygems'
require 'auto'

question :name => "What is your name?"
question :delete => "Delete file when finished? (y/n)"

file "#{@name}.txt" do |f|
  f &lt;&lt; 'Append to text file'
  f = 'Overwrite text file'
end

file("#{@name}.txt").delete if @delete
</pre>

Save it and run it like you would any other Ruby script.

In this example, <code>question</code> and <code>file</code> are both methods provided by the plugins <code>auto-question</code> and <code>auto-file</code>, respectively. They are included when you install the <code>auto</code> gem, but other plugins can be obtained via Rubygems.

Tasks
-----

Auto has a tasks system similar to Capistrano or Rake. In the previous example, if you had saved your script to <code>~/.auto/my/name.rb</code>, you would be able to run it by executing <code>auto my:name</code> in Terminal.

Tasks may also be included via plugin. See the **Authoring Plugins** section for more information.

Sessions
--------

Installing the <code>auto</code> gem also installs <code>auto-session</code>, which allows you to record the input to your Auto scripts and replay them later.

To save a session, run your script or task with the <code>SESSION</code> environment variable:

<pre>
SESSION=name ruby my_name.rb
SESSION=name auto my:name
</pre>

This session would be saved in <code>~/.auto/session/name.rb</code> (run it by executing <code>auto session:name</code>). It might look like this:

<pre>
answer :name => 'Joe'
answer :delete => false
run 'my:name'
</pre>

The session script is executed as any other Auto script. This is cool because you can modify your session files to get custom input for certain questions.

<pre>
question :name => "What is your last name?"
answer :delete => false
run 'my:name'
</pre>

You also could have deleted the <code>:name</code> answer to ask that question upon running the session.

Authoring Plugins
-----------------

Plugins have a lib directory just like any other gem. Here is how the lib file for the Foo plugin might look:

<pre>
# lib/auto/foo.rb
module Auto
  module Foo

    def foo(*args)
      Foo.instance args
    end

    class Foo
      class &lt;&lt;self
      
        def instance(args)
          # Do something
        end
      end
    end
  end
end
</pre>

Auto uses the gem name (<code>auto-foo</code>) to find <code>lib/auto/foo.rb</code> and include <code>Auto::Foo</code> into the environment. Now you can call the <code>foo</code> method in any of your Auto scripts.

Auto plugins must have gem names with <code>auto-</code> as a prefix to be automatically required.

Include Auto tasks with your plugin by adding a <code>.auto</code> directory to your gem, just as you do with your home directory (<code>~/.auto</code>).