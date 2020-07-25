$listen_port = '80'
$service =  'loadbalancerservice'
$webserver1_name = 'webserver1'
$webserver2_name = 'webserver2'
$health_check = 'check'
$node_exporter_version = '1.0.1'
$prometheus_node_exporter_class = 'prometheus::node_exporter'
node 'default' {
  include ::docker
  include ::haproxy
  haproxy::listen { $service:
    collect_exported => false,
    ipaddress        => '10.0.0.2',
    ports            => $listen_port,
  }
  haproxy::balancermember { $webserver1_name:
    listening_service => $service,
    server_names      => $webserver1_name,
    ipaddresses       => '10.0.0.3',
    ports             => $listen_port,
    options           => $health_check,
  }
  haproxy::balancermember { $webserver2_name:
    listening_service => $service,
    server_names      => $webserver2_name,
    ipaddresses       => '10.0.0.4',
    ports             => $listen_port,
    options           => $health_check,
  }
  class { 'prometheus':
  manage_prometheus_server => true,
  version                  => '2.19.3',
  alerts                   => {
    'groups' => [
      {
        'name'  => 'alert.rules',
        'rules' => [
          {
            'alert'       => 'cpUsage',
            'expr'        => '100 - (avg by (instance) (irate(node_cpu_seconds_total{job="node_exporter",mode="idle"}[5m])) * 100) > 80',
            'labels'      => {'severity' => 'critical'},
            'annotations' => {
              'summary'     => 'WebServer Cpu usage is above than 80 percentage',
            }},           {
            'alert'       => 'MemoryUsage',
            'expr'        => '((node_memory_MemTotal_bytes -  node_memory_MemFree_bytes))  / (node_memory_MemTotal_bytes) * 100 > 80',
            'labels'      => {'severity' => 'critical'},
            'annotations' => {
              'summary'     => 'WebServer Memory usage is above than 80 percentage',
            }},
            {
            'alert'       => 'WebServerStatus',
            'expr'        => 'probe_success == 0',
            'labels'      => {'severity' => 'critical'},
            'annotations' => {
              'summary'     => 'Webserver nginx server is down in one of the server',
            }
          }
        ],
      },
    ],
  },
  global_config            => {
    'scrape_interval'     => '15s',
    'evaluation_interval' =>  '15s'
  },
  scrape_configs           => [
    {
      'job_name'        => 'prometheus',
      'scrape_interval' => '5s',
      'static_configs'  => [
        {
          'targets' => ['10.0.0.2:9090'],
          'labels'  => {'alias' => 'prometheus'}
        }
      ],
    },
    {
      'job_name'        => 'node_exporter',
      'scrape_interval' => '5s',
      'static_configs'  => [
        {
          'targets' => ['10.0.0.3:9100','10.0.0.4:9100', '10.0.0.2:9100'],
          'labels'  => {'alias' => 'node_exporter'}
        },
      ],
    },
    {
      'job_name'        => 'blackbox_exporter',
      'scrape_interval' => '5s',
      'metrics_path'    => '/probe',
      'params'          => { 'module' => [
        'http_2xx'
      ]
      },
      'static_configs'  => [
        {
          'targets' => [
            '10.0.0.3:80',
            '10.0.0.4:80',
            '10.0.0.2:80'
          ]
        }
      ],
      'relabel_configs' => [
    {
      'source_labels' => [
        '__address__'
      ],
      'target_label'  => '__param_target'
    },
    {
      'source_labels' => [
        '__param_target'
      ],
      'target_label'  => 'instance'
    },
    {
      'target_label' =>  '__address__',
      'replacement'  => '10.0.0.2:9115'
    }
  ]
    },
  ],
  alertmanagers_config     => [
    {
      'static_configs' => [
        {
          'targets' => [
            '10.0.0.2:9093']
        }
      ],
    },
  ]
}

class { 'prometheus::alertmanager':
    version => '0.21.0',
    global  => {
    'smtp_smarthost'     => 'smtp.gmail.com:587',
    'smtp_from'          => 'lidortestbring@gmail.com',
    'smtp_auth_username' => 'lidortestbring',
    'smtp_auth_password' =>  'BringTest',
    'smtp_require_tls'   => true
  },
    route   =>  {

    'repeat_interval' => '1m',
    'receiver'        => 'recipients'
  },
  receivers => [
    {
      'name'          => 'recipients',
      'email_configs' => [
        {
          'to'        => 'lidorabo2@gmail.com'
        },
      ],
    },
  ],
}
class { 'prometheus::blackbox_exporter':
    version => '0.17.0',
    modules => {
    'http_2xx'          => {
      'prober'  => 'http',
      'timeout' => '5s',
      'http'    => {
      'valid_status_codes' => [],
      'method'             => 'GET'
      }
    }
  }
}
class { $prometheus_node_exporter_class:
  version        => $node_exporter_version,
}
}
node 'webserver1' {
  # Applies only to mentioned node. If nothing mentioned, applies to all.
class { $prometheus_node_exporter_class:
  version        =>  $node_exporter_version,
}
        include webserver
}
node 'webserver2' {
class { $prometheus_node_exporter_class:
  version        => $node_exporter_version,
}
    include webserver

}


