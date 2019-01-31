/*
 * https://raw.githubusercontent.com/elastic/logstash/master/x-pack/src/test/java/org/logstash/xpack/test/RSpecTests.java
 */
package org.logstash.xpack.test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import org.jruby.runtime.builtin.IRubyObject;
import org.junit.Assert;
import org.junit.Test;
import org.logstash.RubyUtil;
import org.logstash.Rubyfier;

public final class RSpecTests {
    @Test
    public void rspecTests() throws Exception {
        RubyUtil.RUBY.getENV().put("IS_JUNIT_RUN", "true");
        RubyUtil.RUBY.getGlobalVariables().set(
            "$JUNIT_ARGV", Rubyfier.deep(RubyUtil.RUBY, Arrays.asList(
                "-fd", "--pattern", "spec/**/*_spec.rb"
            ))
        );
        final Path rspec = Paths.get(
            org.assertj.core.util.Files.currentFolder().getParent(), "lib/bootstrap/rspec.rb"
        );
        final IRubyObject result = RubyUtil.RUBY.executeScript(
            new String(Files.readAllBytes(rspec), StandardCharsets.UTF_8),
            rspec.toFile().getAbsolutePath()
        );
        if (!result.toJava(Long.class).equals(0L)) {
            Assert.fail("RSpec test suit saw at least one failure.");
        }
    }
}
