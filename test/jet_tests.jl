@testitem "JET" begin
    using Test
    using JET
    @testset "JET" begin
        JET.test_package(DocumenterTranslationOpenAIBackend; target_defined_modules = true)
    end
end
