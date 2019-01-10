package test

import (
	"strings"
	"testing"
    "./helper"
	
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/stretchr/testify/assert"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"terraform-module-test-lib"
)

func TestModulehadoopQuickStart(t *testing.T) {
	terraformDir := "../examples/quick_start"

	terraformOptions := configureTerraformOptions(t, terraformDir)

	defer test_structure.RunTestStage(t, "destroy", func() {
		logger.Log(t, "terraform destroy ...")
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "init", func() {
		logger.Log(t, "terraform init ...")
		terraform.Init(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		logger.Log(t, "terraform apply ...")
		terraform.Apply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		logger.Log(t, "Verfiying  ...")
		validateSolution(t, terraformOptions)
	})
}

func configureTerraformOptions(t *testing.T, terraformDir string) *terraform.Options {
	var vars Inputs
	err := test_helper.GetConfig("inputs_config.json", &vars)
	if err != nil {
		logger.Logf(t, err.Error())
		t.Fail()
	}
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"tenancy_ocid":        vars.Tenancy_ocid,
			"user_ocid":           vars.User_ocid,
			"fingerprint":         vars.Fingerprint,
			"region":              vars.Region,
			"compartment_ocid":    vars.Compartment_ocid,
			"private_key_path":    vars.Private_key_path,
			"ssh_authorized_keys": vars.Ssh_authorized_keys,
			"ssh_private_key":     vars.Ssh_private_key,
		},
	}
	return terraformOptions
}

func validateSolution(t *testing.T, terraformOptions *terraform.Options) {
	// build key pair for ssh connections
	ssh_public_key_path := terraformOptions.Vars["ssh_authorized_keys"].(string)
	ssh_private_key_path := terraformOptions.Vars["ssh_private_key"].(string)
	key_pair, err := test_helper.GetKeyPairFromFiles(ssh_public_key_path, ssh_private_key_path)
	if err != nil {
		assert.NotNil(t, key_pair)
	}
	 validateByHTTPGet(t, terraformOptions)
	 validateByWordCountJob(t, terraformOptions, key_pair)
}


func validateByHTTPGet(t *testing.T, terraformOptions *terraform.Options) {
	//Validate WebUI interfaces are accessible
	instanceText :=  "hadoop"
	hdfs_url := terraform.Output(t, terraformOptions, "Hadoop_Namenode_Web_UI")
	resource_manager_url := terraform.Output(t, terraformOptions, "Hadoop_Resource_Manager_Web_UI")
	job_history_url := terraform.Output(t, terraformOptions, "Hadoop_Job_History_Server_Web_UI")
    	http_helper.HttpGetWithCustomValidation(t, hdfs_url, func(statusCode int,body string) bool {
                        return statusCode == 200 
                })
	http_helper.HttpGetWithCustomValidation(t, resource_manager_url, func(statusCode int,body string) bool {
                        return statusCode == 200 && (strings.Contains(body, instanceText) )
                })
    http_helper.HttpGetWithCustomValidation(t, job_history_url, func(statusCode int,body string) bool {
                        return statusCode == 200 && (strings.Contains(body, instanceText) )
                })
	

}

func  validateByWordCountJob(t *testing.T, terraformOptions *terraform.Options, key_pair *ssh.KeyPair) {
	//Run a sample wordcount MapReduce Job to validate the solution
	command := `hdfs dfs -rm -r /user; 
		    hdfs dfs -mkdir /user; 
		    hdfs dfs -copyFromLocal /usr/share/dict /user/dft; 
		    hadoop jar $HADOOP_COMMON_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar  wordcount /user/dft /user/dft-output`
	bastion_public_ip := terraform.Output(t, terraformOptions, "Bastion_Public_IP")
	slave_private_ips := terraform.Output(t, terraformOptions, "Hadoop_Data_Node_private_ips")
	private_ips := strings.Split(slave_private_ips, ",")
	slave_private_ip := strings.TrimSpace(private_ips[1])
	result := test_helper.SSHToPrivateHost(t, bastion_public_ip, slave_private_ip, "opc", key_pair, command)
	assert.True(t, strings.Contains(result, "completed successfully"))
}
