
define :mysql_database, {
} do
  mysql_database_params = params

  config = extract_config mysql_database_params[:name]

  if config[:host] == "localhost" && node.mysql[:run_sql]

    unless config[:password]
      config[:password] = local_storage_read("mysql_password:#{config[:username]}") do
        PasswordGenerator.generate 32
      end
    end

    root_mysql_password = mysql_password "root"

    users = [{:username => config[:username], :host => "localhost"}]
    users << {:username => config[:username], :host => "%"} unless node.mysql.engine_config.mysqld.bind_address == "127.0.0.1"

    execute "create msqyl database #{config[:database]}" do
      command "echo \"CREATE DATABASE IF NOT EXISTS #{config[:database]};\" | mysql --user=root --password=#{root_mysql_password}"
      not_if "echo 'SHOW DATABASES' | mysql --skip-column-names --user=root --password=#{root_mysql_password} | grep #{config[:database]}"
    end

    users.each do |u|

      execute "create mysql user #{u}" do
        command "echo \"CREATE USER \\\"#{u[:username]}\\\"@\\\"#{u[:host]}\\\" IDENTIFIED BY \\\"#{config[:password]}\\\";\" | mysql --user=root --password=#{root_mysql_password}"
        not_if "echo 'SELECT User,Host FROM mysql.user;' | mysql --skip-column-names --user=root --password=#{root_mysql_password} | grep -v root | grep #{u[:username]} | grep #{u[:host]}"
      end

      execute "grant mysql user #{u} to #{config[:database]}" do
        command "echo \"GRANT ALL PRIVILEGES ON #{config[:database]} . * TO \\\"#{u[:username]}\\\"@\\\"#{u[:host]}\\\";\" | mysql --user=root --password=#{root_mysql_password}"
        not_if "echo 'select Db, User, Host FROM mysql.db;' | mysql --skip-column-names --user=root --password=#{root_mysql_password} | grep -v root | grep #{u[:username]} | grep #{u[:host]} | grep #{config[:database]}"
      end

    end

  end

  if config[:mysql_wrapper]

    template config[:mysql_wrapper][:file] do
      cookbook "mysql"
      source "mysql.sh.erb"
      variables :config => config
      mode '0700'
      owner config[:mysql_wrapper][:owner]
      action :nothing
    end

    # directory enclosing wrapper file is often created after, or does not exists (server with db only)
    delayed_exec "create #{config[:mysql_wrapper][:file]}" do
      after_block_notifies :create, "template[#{config[:mysql_wrapper][:file]}]"
      block do
        File.exists? File.dirname(config[:mysql_wrapper][:file])
      end
    end

  end

end