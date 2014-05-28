require 'open3'
require 'fileutils'

module TrickBag

  # Creates and optionally writes to file a scriopt that will check to see that
  # the gemspec/Gemfile includes all necessary gems.
  #
  # Testing this by doing a simple 'require' instead does not test for the
  # possibility that the gem was installed prior to the call to bundle.
  #
  # This script will create a new empty gemset and run bundle on that
  # so we can know that any gems there were put there by the bundle call.
  #
  # Assumes the presence of rvm and that the script is run in the project root.
  # Assumes also that any *gem files in the project root are not needed, and deletes them!
  #
  # Call one of the methods to get the script content, and be sure to source it when you
  # run it, otherwise rvm may complain that it is not a login shell.  For example,
  # gem install trick_bag and then, in your gem project root do:
  #
  # ruby -e "require 'trick_bag'; TrickBag::GemDependencyScript.write_script_for('trick_bag', 'test2')" && . ./test2
  module GemDependencyScript

    module_function

    DEFAULT_SCRIPT_NAME = 'test_bundle_gems'

    # The 'default' gemset activated by the command 'rvm gemset use default'
    # will have the name of the active Ruby, so, for example:
    #
    # > rvm gemset use default
    # Using ruby-2.1.0 with gemset default
    # > rvm gemset name
    # /Users/kbennett/.rvm/gems/ruby-2.1.0
    # > rvm current
    # ruby-2.1.0
    #
    # ...so when we get the gemset name to use later to restore the original gemset,
    # we need to convert names like '/Users/kbennett/.rvm/gems/ruby-2.1.0' to 'default'.
    # That's what this script does.
    GEMSET_NAME_SCRIPT = %q{
gemset_name()
{
  RUBY=`rvm current`
  GEMSET=`rvm gemset name`

  if [ "x$(echo $GEMSET | grep "${RUBY}$")" = "x" ] ; then
    NAME=$GEMSET
  else
    NAME='default'
  fi
  echo $NAME
}

}

    # Returns a string containing a shell script that will test the gem (see above for details).
    def script_for(gem_name, script_name = DEFAULT_SCRIPT_NAME)
      require_command = "require '#{gem_name}'"

      "#!#{ENV['SHELL']}\n" + GEMSET_NAME_SCRIPT +

          [
            "echo This script must be sourced due to rvm constraints, e.g.: . ./#{script_name}",
            %Q{echo \"and was generated by TrickBag::GemDependencyScript (see https://github.com/keithrbennett/trick_bag/).\"},
            "echo Lines output by this script are preceded by a colon and a space.",
            "echo Pipe output to grep \"^:\" for terser output.",
            "echo If this script aborts prematurely, you may need to manually restore your gemset, e.g.:",
            "echo rvm gemset use default",
            "export ORIG_GEMSET_NAME=$(gemset_name)",
            "echo : Preserving original gemset name $ORIG_GEMSET_NAME.",
            "export TEMP_GEMSET_NAME=gem_dep_checker_gemset",
            "rvm gemset create $TEMP_GEMSET_NAME",
            "rvm gemset use $TEMP_GEMSET_NAME",
            "echo : Creating and using temporary gemset name of $TEMP_GEMSET_NAME.",
            "echo : Using gemset: `rvm gemset name`",
            "bundle install",
            "gem build *gemspec",
            "gem install *gem",
            "echo : Testing #{require_command}",
            %Q{ruby -e "#{require_command}"},
            "echo : Require successful",
            "rvm gemset use $ORIG_GEMSET_NAME",
            "echo : Restored gemset to original gemset: `rvm gemset name`",
            "rvm gemset delete --force $TEMP_GEMSET_NAME",
            "echo : Deleted temporary gemset $TEMP_GEMSET_NAME",
            "echo : Bundle, build, install, and require of gem all successful."
          ].join("   &&  \\\n") +

        "\n"
    end


    # Writes to file a a shell script that will test the gem (see above for details),
    # and sets the permission to be executable so it can be run as a shell command.
    def write_script_for(gem_name, filespec = DEFAULT_SCRIPT_NAME)
      File.write(filespec, script_for(gem_name, filespec))
      FileUtils.chmod("u=wrx,go=rx", filespec)
    end
  end
end

