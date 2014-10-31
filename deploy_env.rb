#!/usr/bin/env ruby

=begin rdoc
  == Purpose
  Use Git's post-receive hook to deploy dynamic Puppet environments with
  r10k[https://github.com/adrienthebo/r10k].

  == License
  Copyright (c) 2014 Todd A. Jacobs

  This program is free software: you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation, either version 3 of the License, or (at your option) any later
  version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along with
  this program. If not, see Licenses[http://www.gnu.org/licenses/].

  == Setup
  - Make sure r10k and the correct Ruby version are both in the PATH when
    running sudo, especially if you're using Puppet Enterprise or a Ruby version
    manager like RVM, rbenv, or chruby.
  - Rename this file to .git/hooks/post-receive in an r10k-tracked repository.
  - Make hook executable: <code>chmod 755 .git/hooks/post-receive</code>
  - Push as usual.
=end

# Loop over standard input and deploy a Puppet environment for every
# pushed branch except "production", which should generally be deployed
# through your change control process. Also skip any environment names
# considered invalid because they conflict with Puppet config sections.
gets.chomp.split.each_slice(3) do |stdin|
  branch = stdin[2]
  case branch
  when 'production'
    warn "Please deploy branch through change control: #{branch}"
    next
  when 'main', 'master', 'agent', 'user'
    warn "Invalid environment name: #{branch}"
    next
  else
    cmd = %w[ sudo r10k -v info deploy #{branch} ]
    IO.popen(cmd) do { |io| puts io.read }
  end
end
