#ifndef SDL_HH
    #define SDL_HH
    #include <SDL2/SDL.h>
#endif
#ifndef LUA_FUNCTION_H
    #include "../Lua-Adapter/LuaFunction.hpp"
#endif

SDL_Renderer* renderer {nullptr};

int sdl_set_color(lua_State *L) {
    if(!L)
        return 1;
    const unsigned char r {(unsigned char)(lua_tointeger(L, 1))};
    const unsigned char g {(unsigned char)(lua_tointeger(L, 2))};
    const unsigned char b {(unsigned char)(lua_tointeger(L, 3))};
    const unsigned char a {(unsigned char)(lua_tointeger(L, 4))};
    SDL_SetRenderDrawColor(renderer, r, g, b, a);
    return 0;
}

int sdl_fill_rect(lua_State *L) {
  if(!L)
    return 1;
  const SDL_Rect rect {
      lua_tointeger(L, 1),
      lua_tointeger(L, 2),
      lua_tointeger(L, 3),
      lua_tointeger(L, 4)
  };
  SDL_RenderFillRect(renderer, &rect);
  return 0;
}

int sdl_draw_rect(lua_State *L) {
  if(!L)
    return 1;
  const SDL_Rect rect {
      lua_tointeger(L, 1),
      lua_tointeger(L, 2),
      lua_tointeger(L, 3),
      lua_tointeger(L, 4)
  };
  SDL_RenderDrawRect(renderer, &rect);
  return 0;
}

int sdl_render(lua_State *L) {
  if(!L)
    return 1;
  SDL_RenderPresent(renderer);
  return 0;
}

int delay(lua_State *L) {
  if(!L)
    return 1;
     struct timespec time_spec;

    time_spec.tv_sec = lua_tointeger(L, 1);
    time_spec.tv_nsec = lua_tointeger(L, 2);

    nanosleep(&time_spec, nullptr);
    return 0;
}

int main( ){
    constexpr unsigned short int DEFAULT_SCREEN_WIDTH = 800;
    constexpr unsigned short int DEFAULT_SCREEN_HEIGHT = 480;
    const std::string FILE_APPLICATION {"app.lua"};

    LuaAdapter lua;
    LuaFunction function{lua};
    if( (function.Push(sdl_fill_rect, "sdl_fill_rect") == false)
    or  (function.Push(sdl_draw_rect, "sdl_draw_rect") == false)
    or  (function.Push(sdl_set_color, "sdl_set_color") == false)
    or  (function.Push(sdl_render, "sdl_render") == false)
    or  (function.Push(delay, "delay") == false)
    )   {
        std::cout << "Error: Could not push C-Functions to Lua!";
    }

    if(lua.Load(FILE_APPLICATION)==false){
        std::cout << "Error: Could not load '"<< FILE_APPLICATION << "'!";
        return 1;
    }
    signed int SCREEN_WIDTH {DEFAULT_SCREEN_WIDTH};
    if(lua.Get("SCREEN_WIDTH", SCREEN_WIDTH)== false)
        std::cout << "Error: Could not load 'SCREEN_WIDTH' from Lua!";

    signed int SCREEN_HEIGHT {DEFAULT_SCREEN_HEIGHT};
    if(lua.Get("SCREEN_HEIGHT", SCREEN_HEIGHT) == false)
        std::cout << "Error: Could not load 'SCREEN_HEIGHT' from Lua!";

    if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 ) {
        return 1;
    }

    SDL_Window *window {
        SDL_CreateWindow(
            "Lua-Render v0.01",
            100, 100,
            SCREEN_WIDTH,
            SCREEN_HEIGHT,
            0
        )
    };
    if(!window) {
        SDL_Quit();
        std::cout << "Error: Could not open the window! \n";
        lua.Close();
        return 1;
    }

    renderer = SDL_CreateRenderer(
        window, -1,
        SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_TARGETTEXTURE
    );

    if(!renderer) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        std::cout << "Error: Could not create a rendering-context! \n";
        lua.Close();
        return 1;
    }

    SDL_RenderSetLogicalSize(
        renderer,
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    );

    function.Call("main");

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    lua.Close();
    return 0;
}
