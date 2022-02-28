#
# Cookbook:: selinux
# Resource:: boolean
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unified_mode true

property :boolean, String,
          name_property: true,
          description: 'SELinux boolean to set'

property :value, [Integer, String, true, false],
          required: true,
          equal_to: %w(on off),
          coerce: proc { |p| SELinux::Cookbook::BooleanHelpers.selinux_bool(p) },
          description: 'SELinux boolean value'

property :persistent, [true, false],
          default: true,
          desired_state: false,
          description: 'Set to true for value setting to survive reboot'

load_current_value do |new_resource|
  value shell_out!("getsebool #{new_resource.boolean}").stdout.split('-->').map(&:strip).last
end

action_class do
  include SELinux::Cookbook::StateHelpers
end

action :set do
  if selinux_disabled?
    Chef::Log.warn("Unable to set SELinux boolean #{new_resource.name} as SELinux is disabled")
    return
  end

  converge_if_changed do
    cmd = 'setsebool'
    cmd += ' -P' if new_resource.persistent
    cmd += " #{new_resource.boolean} #{new_resource.value}"

    shell_out!(cmd)
  end
end
