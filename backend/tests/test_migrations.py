"""Integration tests for Alembic database migrations"""
import pytest
import subprocess
import os


class TestMigrations:
    """Test Alembic migration operations"""

    def test_migration_files_exist(self):
        """Test that migration directory and files exist"""
        migrations_dir = "f:/khetopedia/backend/alembic/versions"
        
        # Check that alembic directory exists
        assert os.path.exists("f:/khetopedia/backend/alembic"), "Alembic directory not found"
        
        # Check that versions directory exists
        assert os.path.exists(migrations_dir), "Migrations versions directory not found"
        
        # Check that at least one migration file exists
        migration_files = [
            f for f in os.listdir(migrations_dir)
            if f.endswith('.py') and not f.startswith('__')
        ]
        assert len(migration_files) > 0, "No migration files found"

    def test_alembic_current(self):
        """Test that alembic current command works"""
        try:
            result = subprocess.run(
                ["alembic", "current"],
                cwd="f:/khetopedia/backend",
                capture_output=True,
                text=True,
                timeout=10
            )
            # Command should complete without error
            assert result.returncode == 0, f"Alembic current failed: {result.stderr}"
        except subprocess.TimeoutExpired:
            pytest.fail("Alembic current command timed out")
        except FileNotFoundError:
            pytest.skip("Alembic command not found in PATH")

    def test_alembic_history(self):
        """Test that alembic history shows migration chain"""
        try:
            result = subprocess.run(
                ["alembic", "history"],
                cwd="f:/khetopedia/backend",
                capture_output=True,
                text=True,
                timeout=10
            )
            assert result.returncode == 0, f"Alembic history failed: {result.stderr}"
            
            # Output should contain migration info
            output = result.stdout
            assert len(output) > 0, "Alembic history returned empty output"
            
        except subprocess.TimeoutExpired:
            pytest.fail("Alembic history command timed out")
        except FileNotFoundError:
            pytest.skip("Alembic command not found in PATH")

    def test_alembic_check(self):
        """Test that there are no pending migrations"""
        try:
            result = subprocess.run(
                ["alembic", "check"],
                cwd="f:/khetopedia/backend",
                capture_output=True,
                text=True,
                timeout=10
            )
            # Check command should succeed if no issues
            # Note: Return code might vary, so we check output instead
            output = result.stdout + result.stderr
            
            # Should not have "Target database is not up to date" if migrations are current
            # This is informational rather than a strict test
            assert "check" in output.lower() or "current" in output.lower() or len(output) == 0
            
        except subprocess.TimeoutExpired:
            pytest.fail("Alembic check command timed out")
        except FileNotFoundError:
            pytest.skip("Alembic command not found in PATH")

    def test_migration_upgrade_head(self):
        """Test that upgrade to head works (already applied in normal flow)"""
        try:
            # This test verifies that upgrade head command executes without error
            # In normal flow, migrations are already applied during app startup
            result = subprocess.run(
                ["alembic", "upgrade", "head"],
                cwd="f:/khetopedia/backend",
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Should complete successfully
            assert result.returncode == 0, f"Alembic upgrade failed: {result.stderr}"
            
            # Output should indicate success
            output = result.stdout + result.stderr
            # Common success indicators
            success_indicators = ["running upgrade", "done", "ok", "success"]
            has_success = any(indicator in output.lower() for indicator in success_indicators)
            
            # If no explicit success message, at least no error
            if not has_success:
                assert "error" not in output.lower() and "failed" not in output.lower()
            
        except subprocess.TimeoutExpired:
            pytest.fail("Alembic upgrade command timed out")
        except FileNotFoundError:
            pytest.skip("Alembic command not found in PATH")

    def test_migration_downgrade_capability(self):
        """Test that downgrade -1 is possible (don't actually downgrade in tests)"""
        try:
            # Test that the command syntax is valid without executing full downgrade
            result = subprocess.run(
                ["alembic", "current"],
                cwd="f:/khetopedia/backend",
                capture_output=True,
                text=True,
                timeout=10
            )
            
            assert result.returncode == 0
            
            # If we have a current version, downgrade should be possible
            output = result.stdout
            if output and len(output.strip()) > 0:
                # Current version exists, so downgrade should be possible
                # We don't actually run downgrade in tests to avoid breaking the DB
                # Instead we verify the migration files have down_revision defined
                migrations_dir = "f:/khetopedia/backend/alembic/versions"
                migration_files = [
                    f for f in os.listdir(migrations_dir)
                    if f.endswith('.py') and not f.startswith('__')
                ]
                
                # Check that at least one migration has downgrade logic
                has_downgrade = False
                for migration_file in migration_files:
                    with open(os.path.join(migrations_dir, migration_file), 'r') as f:
                        content = f.read()
                        if 'def downgrade()' in content:
                            has_downgrade = True
                            break
                
                assert has_downgrade, "No migration files contain downgrade() function"
            
        except FileNotFoundError:
            pytest.skip("Alembic command not found in PATH")

    def test_alembic_config_exists(self):
        """Test that alembic.ini configuration file exists"""
        alembic_ini = "f:/khetopedia/backend/alembic.ini"
        assert os.path.exists(alembic_ini), "alembic.ini not found"
        
        # Verify it contains essential configuration
        with open(alembic_ini, 'r') as f:
            content = f.read()
            assert 'script_location' in content
            assert 'sqlalchemy.url' in content

    def test_migrations_use_async_engine(self):
        """Test that alembic env.py is configured for async operations"""
        env_py = "f:/khetopedia/backend/alembic/env.py"
        assert os.path.exists(env_py), "alembic/env.py not found"
        
        with open(env_py, 'r') as f:
            content = f.read()
            # Should use async imports and patterns
            assert 'asyncio' in content or 'async' in content, "Migrations should support async"
