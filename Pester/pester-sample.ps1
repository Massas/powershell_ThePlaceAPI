Import-Module Pester -Force

Describe 'test' {
    It 'add' {
        1 + 1 | Should Be 2
    }
}