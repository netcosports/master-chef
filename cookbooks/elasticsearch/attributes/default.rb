
default[:elasticsearch] = {
  :user => 'elastic',
  :url => 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.3.tar.gz',
  :directory => '/opt/elasticsearch',
  :directory_data => '/opt/elasticsearch_data',
  :directory_logs => '/opt/elasticsearch/logs',
  :logs => {
    :general => 'elastic.log',
    :indexing_slowlog => 'elastic_index_indexing_slowlog.log',
    :search_slowlog => 'elastic_index_search_slowlog.log',
  },
  :java_opts => '',
  :env_vars => {},
  :command_line_options => '',
  :host => '127.0.0.1',
  :http_port => 9200,
  :tcp_port => 9300,
  :cluster_name => 'elasticsearch',
  :one_node_mode => true,
  :allow_dynamic_scripts => true,
  :mlockall => true,
  :enable_logs => true,
  :enable_gc_logs => false,
  :configure_zeromq_river => {
    :enable => true,
    :address => 'tcp://127.0.0.1:9700',
  },
  :plugins => {
    :head => {
      :enable => true,
      :id => 'mobz/elasticsearch-head'
    },
    :hq => {
      :enable => true,
      :id => 'royrusso/elasticsearch-HQ'
    },
    :zeromq_river => {
      :enable => true,
      :id => 'bpaquet/elasticsearch-river-zeromq/0.0.5',
      :url => ' https://github.com/bpaquet/elasticsearch-river-zeromq/releases/download/elasticsearch-river-zeromq-0.0.5/elasticsearch-river-zeromq-0.0.5.zip',
    }
  }
}