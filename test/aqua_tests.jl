@testitem "Aqua" begin
    using Aqua
    using Test
    using DocumenterTranslationOpenAIBackend
    @testset "Aqua" begin
        Aqua.test_all(DocumenterTranslationOpenAIBackend)
    end
end
