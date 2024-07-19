local ffi = require('ffi')

ffi.cdef[[
uint16_t htons(uint16_t hostshort);
uint16_t ntohs(uint16_t netshort);
uint32_t inet_addr(const char *cp);

typedef unsigned short int sa_family_t;
typedef uint16_t in_port_t;
typedef uint32_t in_addr_t;

struct sockaddr {
  sa_family_t sa_family;
  char        sa_data[14];
};

struct in_addr {
  in_addr_t s_addr;
};

struct sockaddr_in {
  sa_family_t     sin_family; /* AF_INET */
  in_port_t       sin_port;   /* Port number */
  struct in_addr  sin_addr;   /* IPv4 address */

  // Дополнительные нулевые байты для выравнивания структуры (чзх?)
  // Без этого не работает ¯\_(ツ)_/¯
  unsigned char sin_zero[sizeof(struct sockaddr) -
       sizeof(sa_family_t) -
       sizeof(in_port_t) -
       sizeof(struct in_addr)];
};

int socket(int domain, int type, int protocol);

typedef int socklen_t;
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

int listen(int sockfd, int backlog);

int accept(int socket, struct sockaddr *restrict address,
           socklen_t *restrict address_len);

int connect(int sockfd, const struct sockaddr *addr,
                   socklen_t addrlen);

ssize_t send(int sockfd, const void *buf, size_t len, int flags);

ssize_t read(int fd, void *buf, size_t count);

ssize_t recv(int sockfd, void *buf, size_t len,
                        int flags);

int close(int fd);

const char *inet_ntoa(struct in_addr in);

int setsockopt(int sockfd, int level, int optname,
    const void *optval, socklen_t optlen);

// Для установки таймаута соединения
struct timeval {
  long tv_sec;
  long tv_usec;
};
]]
