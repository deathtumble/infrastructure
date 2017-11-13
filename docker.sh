docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -client=10.0.0.68 -bind=10.0.0.68 -retry-join "provider=aws tag_key=ConsulCluster tag_value=poc.poc" -bootstrap-expect=1 -ui

gosu consul consul agent -data-dir=/consul/data -config-dir=/consul/config -bind=10.0.0.68 -client=10.0.0.68 -server -retry-join "provider=aws tag_key=ConsulCluster tag_value=poc-poc" -bootstrap-expect=3 -ui
gosu consul consul agent -data-dir=/consul/data -config-dir=/consul/config -server -client=10.0.0.68 -bind=10.0.0.68 -retry-join provider=aws tag_key=ConsulCluster tag_value=poc.poc -bootstrap-expect=1 -ui

\"provider=aws tag_key=ConsulCluster tag_value=${var.nameTag}\"