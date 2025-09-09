# Cadence Example Plugins

A collection of example AI agent plugins for the Cadence Framework, built using the Cadence SDK.

## Overview

This repository contains example plugins that demonstrate how to build custom AI agents and tools for the Cadence
multi-agent framework using the Cadence SDK. These plugins showcase various capabilities including mathematical
operations,
web search, and general information handling, serving as templates for building your own plugins.

## Available Plugins

### Math Agent (`mathematics`)

A specialized agent for mathematical calculations and problem-solving using the Cadence SDK.

**Features:**

- Basic arithmetic operations (addition, subtraction, multiplication, division)
- Advanced operations (exponentiation, modulo)
- Error handling for edge cases (division by zero, overflow)
- Structured response schemas with operation tracking
- Step-by-step calculation explanations

**Capabilities:**

- `addition`, `subtraction`, `multiplication`, `division`, `power`, `modulo`

**Usage:**

```python
from cadence_example_plugins.math_agent.plugin import MathPlugin

plugin = MathPlugin()
agent = plugin.create_agent()
# The agent is used by the Cadence framework automatically
```

### Search Agent (`browse_internet`)

A web search agent for information retrieval and research using DuckDuckGo API.

**Features:**

- Web search capabilities with DuckDuckGo integration
- News search for current events
- Image search for visual content
- Structured response schemas with title, description, and links
- Source citation and thumbnail support
- Multi-query support with intelligent search selection

**Capabilities:**

- `web_search`, `news_search`, `image_search`

**Usage:**

```python
from cadence_example_plugins.search_agent.plugin import SearchPlugin

plugin = SearchPlugin()
agent = plugin.create_agent()
# The agent is used by the Cadence framework automatically
```

### Info Agent (`myinfo`)

A general-purpose information and utility agent for chatbot self-introduction and information handling.

**Features:**

- General knowledge queries and information handling
- Self-introduction capabilities
- Context-aware responses
- Simple utility functions

**Capabilities:**

- `my_info`

**Usage:**

```python
from cadence_example_plugins.myinfo_agent.plugin import MyInfoPlugin

plugin = MyInfoPlugin()
agent = plugin.create_agent()
# The agent is used by the Cadence framework automatically
```

## Plugin Structure

Each plugin follows a standard structure using the Cadence SDK and is automatically discovered by the framework.

### Plugin Discovery

Plugins are automatically discovered by the Cadence framework through the SDK's plugin discovery system. No manual
registration is required - the framework scans for plugins that inherit from `BasePlugin`.

### Directory Structure

```
plugin_name/
├── __init__.py          # Plugin initialization
├── agent.py             # Agent implementation
├── tools.py             # Tool definitions
└── plugin.py            # Plugin metadata and factory
```

### Example Plugin Structure

```python
# plugin.py
from cadence_sdk import BasePlugin, PluginMetadata
from cadence_sdk.decorators import object_schema
from typing import TypedDict, Annotated


@object_schema
class ExampleResponseSchema(TypedDict):
    """Schema for plugin response structure."""
    result: Annotated[str, "The result of the operation"]


class ExamplePlugin(BasePlugin):
    @staticmethod
    def get_metadata() -> PluginMetadata:
        return PluginMetadata(
            name="example_plugin",
            version="1.3.1",
            description="An example plugin for demonstration",
            capabilities=["example"],
            agent_type="specialized",
            response_schema=ExampleResponseSchema,
            response_suggestion="When presenting results, be clear and concise.",
            llm_requirements={
                "provider": "openai",
                "model": "gpt-4.1",
                "temperature": 0.1,
                "max_tokens": 1024,
            },
            dependencies=["cadence-sdk>=1.3.1,<2.0.0"]
        )

    @staticmethod
    def create_agent():
        from .agent import ExampleAgent
        return ExampleAgent(ExamplePlugin.get_metadata())

    @staticmethod
    def health_check() -> dict:
        """Perform health check for the plugin."""
        try:
            return {
                "healthy": True,
                "details": "Example plugin is operational",
                "checks": {"basic_functionality": "OK"}
            }
        except Exception as e:
            return {
                "healthy": False,
                "details": f"Example plugin health check failed: {e}",
                "error": str(e)
            }


# agent.py
from cadence_sdk import BaseAgent
from cadence_sdk.base.metadata import PluginMetadata


class ExampleAgent(BaseAgent):
    def __init__(self, metadata: PluginMetadata):
        super().__init__(metadata)

    def get_tools(self):
        from .tools import example_tools
        return example_tools

    def get_system_prompt(self) -> str:
        return "You are an example agent for demonstration purposes."


# tools.py
from cadence_sdk import tool


@tool
def example_tool(input_data: str) -> str:
    """An example tool for demonstration.

    Args:
        input_data: Input data to process

    Returns:
        Processed result
    """
    return f"Processed: {input_data}"


example_tools = [example_tool]
```

## Installation

### From Source

```bash
# Clone the main repository
git clone https://github.com/jonaskahn/cadence.git
cd cadence

# Install plugin dependencies
cd plugins
poetry install

# Install in development mode
poetry install --editable
```

### From PyPI

```bash
pip install cadence-example-plugins
# Note: This package is part of the main Cadence repository
```

## Configuration

### Environment Variables

```bash
# Set plugin directories (single path or JSON list)
export CADENCE_PLUGINS_DIR="./plugins/src/cadence_example_plugins"

# Or multiple directories as JSON array
export CADENCE_PLUGINS_DIR='["/path/to/plugins", "/another/path"]'

# Enable directory-based plugin discovery
export CADENCE_ENABLE_DIRECTORY_PLUGINS=true

# Plugin limits (configured in main application)
export CADENCE_MAX_AGENT_HOPS=25
export CADENCE_GRAPH_RECURSION_LIMIT=50
```

### Plugin Discovery

The Cadence framework automatically discovers plugins from:

- Installed packages (via pip) - automatically scanned
- Directory paths (configured via `CADENCE_PLUGINS_DIR`) - when `CADENCE_ENABLE_DIRECTORY_PLUGINS=true`
- SDK-based plugin discovery system

## Development

### Creating a New Plugin

1. **Create plugin directory structure**

   ```bash
   mkdir my_plugin
   cd my_plugin
   touch __init__.py agent.py tool.py plugin.py
   ```

2. **Implement plugin interface**

   ```python
   # plugin.py
   from cadence_sdk import BasePlugin, PluginMetadata

   class MyPlugin(BasePlugin):
       @staticmethod
       def get_metadata() -> PluginMetadata:
           return PluginMetadata(
               name="my_plugin",
               version="1.3.1",
               description="My custom plugin",
               capabilities=["custom"],
               agent_type="specialized",
               llm_requirements={
                   "provider": "openai",
                   "model": "gpt-4.1",
                   "temperature": 0.1,
                   "max_tokens": 1024,
               },
               dependencies=["cadence-sdk>=1.3.1,<2.0.0"]
           )

       @staticmethod
       def create_agent():
           from .agent import MyAgent
           return MyAgent(MyPlugin.get_metadata())

       @staticmethod
       def health_check() -> dict:
           """Perform health check for the plugin."""
           return {
               "healthy": True,
               "details": "My plugin is operational"
           }
   ```

3. **Implement agent**

   ```python
   # agent.py
   from cadence_sdk import BaseAgent
   from cadence_sdk.base.metadata import PluginMetadata

   class MyAgent(BaseAgent):
       def __init__(self, metadata: PluginMetadata):
           super().__init__(metadata)

       def get_tools(self):
           from .tools import my_tools
           return my_tools

       def get_system_prompt(self) -> str:
           return "You are a custom agent. How can I help you?"
   ```

4. **Add tools (optional)**

   ```python
   # tools.py
   from cadence_sdk import tool

   @tool
   def my_tool(input_data: str) -> str:
       """My custom tool for processing data.

       Args:
           input_data: Input data to process

       Returns:
           Processed result
       """
       # Your tool logic here
       return f"Processed: {input_data}"

   my_tools = [my_tool]
   ```

### Testing Your Plugin

```bash
# Run plugin tests
poetry run pytest tests/

# Test with Cadence framework
export CADENCE_PLUGINS_DIR="./my_plugin"
export CADENCE_ENABLE_DIRECTORY_PLUGINS=true
python -m cadence

# Or test from main project directory
cd ..  # Go back to main project
export CADENCE_PLUGINS_DIR="./plugins/src/cadence_example_plugins"
export CADENCE_ENABLE_DIRECTORY_PLUGINS=true
python -m cadence
```

### Plugin Validation

The SDK provides validation utilities:

```python
from cadence_sdk.utils.validation import validate_plugin_structure

errors = validate_plugin_structure(MyPlugin)
if errors:
    print("Validation errors:", errors)
else:
    print("Plugin is valid!")

# Health check
health_status = MyPlugin.health_check()
print(f"Plugin health: {health_status}")
```

## Best Practices

### Plugin Design

1. **Single Responsibility**: Each plugin should have a focused purpose
2. **Clear Interfaces**: Implement required methods with clear contracts
3. **Error Handling**: Gracefully handle errors and provide meaningful messages
4. **Documentation**: Include comprehensive docstrings and examples
5. **Testing**: Write tests for your plugin functionality

### Performance Considerations

1. **Lazy Loading**: Load resources only when needed
2. **Caching**: Cache frequently accessed data
3. **Async Support**: Use async/await for I/O operations
4. **Resource Management**: Properly clean up resources

### Security

1. **Input Validation**: Validate all user inputs
2. **Tool Safety**: Ensure tools are safe to execute
3. **Access Control**: Implement appropriate access controls
4. **Audit Logging**: Log important operations

## Examples

### Advanced Plugin Example

```python
from cadence_sdk import BasePlugin, BaseAgent, PluginMetadata, tool
from cadence_sdk.decorators import object_schema
from typing import TypedDict, Annotated


@object_schema
class WeatherResponseSchema(TypedDict):
    """Schema for weather response."""
    location: Annotated[str, "The location for weather data"]
    temperature: Annotated[str, "Current temperature"]
    condition: Annotated[str, "Weather condition"]


class WeatherPlugin(BasePlugin):
    @staticmethod
    def get_metadata() -> PluginMetadata:
        return PluginMetadata(
            name="weather_plugin",
            version="1.3.1",
            description="Weather information and forecasting",
            capabilities=["weather_forecast", "current_conditions"],
            agent_type="specialized",
            response_schema=WeatherResponseSchema,
            response_suggestion="Present weather information clearly with location and conditions.",
            llm_requirements={
                "provider": "openai",
                "model": "gpt-4.1",
                "temperature": 0.1,
                "max_tokens": 1024,
            },
            dependencies=["cadence-sdk>=1.3.1,<2.0.0", "requests"]
        )

    @staticmethod
    def create_agent():
        from .agent import WeatherAgent
        return WeatherAgent(WeatherPlugin.get_metadata())

    @staticmethod
    def health_check() -> dict:
        """Perform health check for the weather plugin."""
        try:
            return {
                "healthy": True,
                "details": "Weather plugin is operational",
                "checks": {"api_connectivity": "OK"}
            }
        except Exception as e:
            return {
                "healthy": False,
                "details": f"Weather plugin health check failed: {e}",
                "error": str(e)
            }


class WeatherAgent(BaseAgent):
    def __init__(self, metadata: PluginMetadata):
        super().__init__(metadata)

    def get_tools(self):
        from .tools import weather_tools
        return weather_tools

    def get_system_prompt(self) -> str:
        return "You are a weather agent that provides weather information and forecasts."


@tool
def get_weather(location: str) -> str:
    """Get current weather for a location.

    Args:
        location: The location to get weather for

    Returns:
        Weather information for the location
    """
    # Implementation would call weather API
    return f"Weather for {location}: Sunny, 72°F"


weather_tools = [get_weather]
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Standards

- Follow PEP 8 style guidelines
- Use type hints throughout
- Include comprehensive docstrings
- Write tests for new functionality
- Update documentation as needed

## Troubleshooting

### Common Issues

1. **Plugin not discovered**

    - Check plugin directory path
    - Verify plugin structure
    - Check environment variables

2. **Import errors**

    - Verify dependencies are installed
    - Check import paths
    - Ensure plugin is properly structured

3. **Agent not responding**
    - Check agent implementation
    - Verify tool definitions
    - Check error logs

### Getting Help

- Check the [documentation](https://cadence.readthedocs.io/)
- Open an [issue](https://github.com/jonaskahn/cadence/issues)
- Join our [discussions](https://github.com/jonaskahn/cadence/discussions)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [Read the Docs](https://cadence.readthedocs.io/)
- **Issues**: [GitHub Issues](https://github.com/jonaskahn/cadence/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jonaskahn/cadence/discussions)

---

**Built with ❤️ for the Cadence AI community**
