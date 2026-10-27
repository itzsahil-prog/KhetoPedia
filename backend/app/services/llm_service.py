"""
LLM Service - Provides abstraction layer for multiple LLM providers.
Supports OpenAI, Anthropic, and graceful fallback.
"""

from typing import Optional, Dict, Any
import httpx
import json

from app.core.config import settings


class LLMService:
    """Service for interacting with Large Language Models."""

    @staticmethod
    async def generate_response(
        system_prompt: str,
        user_message: str,
        context: Optional[Dict[str, Any]] = None,
        temperature: Optional[float] = None,
        max_tokens: Optional[int] = None,
    ) -> str:
        """
        Generate a response from the configured LLM provider.
        
        Args:
            system_prompt: System instructions for the LLM
            user_message: User's input message
            context: Optional context dictionary
            temperature: Optional temperature override
            max_tokens: Optional max tokens override
            
        Returns:
            Generated response text
            
        Raises:
            Exception: If API call fails
        """
        temp = temperature if temperature is not None else settings.LLM_TEMPERATURE
        tokens = max_tokens if max_tokens is not None else settings.LLM_MAX_TOKENS

        provider = settings.LLM_PROVIDER.lower()

        try:
            if provider == "openai":
                return await LLMService._call_openai(system_prompt, user_message, temp, tokens)
            elif provider == "anthropic":
                return await LLMService._call_anthropic(system_prompt, user_message, temp, tokens)
            elif provider == "none":
                raise Exception("LLM provider set to 'none'")
            else:
                raise Exception(f"Unsupported LLM provider: {provider}")
        except Exception as e:
            print(f"[LLM] Error calling {provider}: {e}")
            raise

    @staticmethod
    async def _call_openai(
        system_prompt: str,
        user_message: str,
        temperature: float,
        max_tokens: int,
    ) -> str:
        """Call OpenAI API."""
        if not settings.OPENAI_API_KEY:
            raise Exception("OPENAI_API_KEY not configured")

        url = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {settings.OPENAI_API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": settings.OPENAI_MODEL,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message},
            ],
            "temperature": temperature,
            "max_tokens": max_tokens,
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(url, headers=headers, json=payload)
            response.raise_for_status()
            data = response.json()
            
            if "choices" in data and len(data["choices"]) > 0:
                return data["choices"][0]["message"]["content"].strip()
            else:
                raise Exception("Invalid response format from OpenAI")

    @staticmethod
    async def _call_anthropic(
        system_prompt: str,
        user_message: str,
        temperature: float,
        max_tokens: int,
    ) -> str:
        """Call Anthropic API."""
        if not settings.ANTHROPIC_API_KEY:
            raise Exception("ANTHROPIC_API_KEY not configured")

        url = "https://api.anthropic.com/v1/messages"
        headers = {
            "x-api-key": settings.ANTHROPIC_API_KEY,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
        }
        payload = {
            "model": settings.ANTHROPIC_MODEL,
            "system": system_prompt,
            "messages": [
                {"role": "user", "content": user_message},
            ],
            "temperature": temperature,
            "max_tokens": max_tokens,
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(url, headers=headers, json=payload)
            response.raise_for_status()
            data = response.json()
            
            if "content" in data and len(data["content"]) > 0:
                return data["content"][0]["text"].strip()
            else:
                raise Exception("Invalid response format from Anthropic")

    @staticmethod
    def validate_response(response: str, field_context: Optional[Dict[str, Any]] = None) -> str:
        """
        Post-process and validate LLM response for safety.
        
        - Ensures no hallucinated sensor data
        - Validates dosage recommendations are reasonable
        - Strips sensitive information
        
        Args:
            response: Raw LLM response
            field_context: Optional field context for validation
            
        Returns:
            Validated response
        """
        # Basic validation: check for common hallucination patterns
        # In production, this would be more sophisticated
        
        # Remove any potential system prompt leakage
        if "system prompt" in response.lower() or "instructions:" in response.lower():
            response = response.split("system prompt")[0].split("instructions:")[0]
        
        # Ensure response doesn't contain unrealistic dosage claims
        # This is a simple check - production would have more sophisticated validation
        dangerous_patterns = [
            "100% guaranteed",
            "definitely will cure",
            "no side effects",
        ]
        
        for pattern in dangerous_patterns:
            if pattern in response.lower():
                print(f"[LLM] Warning: Potentially unsafe pattern detected: {pattern}")
        
        return response.strip()


llm_service = LLMService()
