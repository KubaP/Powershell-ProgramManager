Describe -Verbose "Validating Write-Message" {
	
	InModuleScope -ModuleName ProgramManager {
		
		# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
		Mock Write-Host { }
		Mock Write-Warning { }
		Mock Write-Error { }
		
		It "Given valid parameters: Message '<MessageText>' and flag -<Type>; It should correct write message to correct stream" -TestCases @(
			
			# The different valid messages and flags
			#@{ MessageText = "Test message"; Type = "DisplayText" }
			@{ MessageText = "Test message"; Type = "DisplayWarning" }
			@{ MessageText = "Test message"; Type = "DisplayError" }
			
		) {
			
			# Pass the test case data into test body
			Param ($MessageText, $Type) 
			
			# Run the command to test
			switch ($Type) {
				
				"DisplayText" { Write-Message -Message $MessageText -DisplayText }
				"DisplayWarning" { Write-Message -Message $MessageText -DisplayWarning }
				"DisplayError" { Write-Message -Message $MessageText -DisplayError }
				
			}
			
			# Check that the correct Write<> function is called
			if ($Type -eq "DisplayText") {
				
				Assert-MockCalled Write-Host -Times 1 -Exactly -Scope It -ParameterFilter {
					$Message -eq $MessageText
				}
				
			}elseif ($Type -eq "DisplayWarning") {
				
				Assert-MockCalled Write-Warning -Times 1 -Exactly -Scope It -ParameterFilter {
					$Message -eq $MessageText
				}
				
			}elseif ($Type -eq "DisplayError") {
				
				Assert-MockCalled Write-Error -Times 1 -Exactly -Scope It -ParameterFilter {
					$Message -eq $MessageText
				}
				
			}
			
		}
		
	}
	
}